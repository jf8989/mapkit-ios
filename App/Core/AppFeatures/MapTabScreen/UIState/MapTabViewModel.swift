// App/Core/AppFeatures/MapTabScreen/UIState/MapTabViewModel.swift

import Combine
import CoreLocation
import Foundation

/// ViewModel for the Map tab.
@MainActor
public final class MapTabViewModel: ObservableObject {
    // Inputs
    private let env: AppEnvironment
    private let bag = TaskBag()
    private let permissionManager: PermissionManagerType
    private var permissionRequested = false

    #if DEBUG
        private func dlog(_ msg: String) { print("[MapVM] \(msg)") }
    #endif

    // UI state
    @Published public private(set) var distanceMeters: Double = 0
    @Published public private(set) var visited: [VisitedPlace] = []
    /// Latest known coordinate (nil until we get a real fix). View uses this to center the map.
    @Published public private(set) var currentCoordinate:
        CLLocationCoordinate2D?
    @Published public var alert: AlertState?

    /// Permission gate for Location (nil = authorized / no gate)
    @Published public private(set) var gate: LocationPermissionGate?

    // Selection (for pin tap later)
    @Published public var selectedPlace: VisitedPlace?

    // Internals
    private var isTracking = false
    private var startLocation: CLLocation?
    private var lastCheckpoint: CLLocation?
    private var lastGeocodedCheckpoint: CLLocation?

    // Movement signal (emits when we pass the 20 m gate)
    private let movementSubject = CurrentValueSubject<CLLocation?, Never>(nil)

    // 5-second cadence
    private let timer = Timer.publish(every: 5, on: .main, in: .common)
        .autoconnect()

    public init(env: AppEnvironment) {
        self.env = env
        self.permissionManager = env.permissionManager
    }

    // MARK: - Intents

    public func startTracking() {
        // Idempotent guard: avoid double subscriptions.
        #if DEBUG
            dlog("startTracking() called. isTracking=\(isTracking)")
        #endif
        if isTracking { return }
        isTracking = true

        // 0) Permission flow — manager-as-router (request once; show gate only when denied)
        permissionManager.locationGate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                switch state {
                case .authorized:
                    self.gate = nil
                case .needsRequest:
                    if !self.permissionRequested {
                        self.permissionRequested = true
                        self.permissionManager.requestLocationPermission()  // system prompt “right there”
                    }
                case .needsSettings:
                    self.gate = .needsSettings  // View shows a single-OK overlay; no settings deep link
                }
            }
            .store(in: &bag.cancellables)

        // React to authorization changes (includes the current value on subscribe).
        env.locationService.authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .authorizedAlways, .authorizedWhenInUse:
                    #if DEBUG
                        dlog("auth=\(status) → startUpdatingLocation()")
                    #endif
                    self.env.locationService.startUpdates()
                case .denied, .restricted:
                    #if DEBUG
                        dlog(
                            "auth=\(status) → stopUpdatingLocation(); alert not authorized"
                        )
                    #endif
                    self.env.locationService.stopUpdates()
                    self.alert = AlertState(
                        title: "Location Permission",
                        message: AppError.notAuthorized.userMessage
                    )
                case .notDetermined:
                    break
                @unknown default:
                    break
                }
            }
            .store(in: &bag.cancellables)

        // 1) Process raw locations → 20m gate + distance accumulation
        env.locationService.locationUpdates
            .receive(on: DispatchQueue.main)  // UI updates on main
            .sink { [weak self] location in
                guard let self else { return }

                if self.startLocation == nil {
                    self.startLocation = location
                    self.lastCheckpoint = location

                    // One-shot immediate reverse-geocode on the very first fix.
                    // UX: show the first pin right away (no 5s wait, no ≥20m gate).
                    self.env.geocodingService
                        .reverseGeocode(location: location)
                        .catch { [weak self] _ -> Just<[CLPlacemark]> in
                            self?.alert = AlertState(
                                title: "Error",
                                message: AppError.geocodingFailed.userMessage
                            )
                            return Just([])
                        }
                        .receive(on: DispatchQueue.main)
                        .sink { [weak self] placemarks in
                            guard let self else { return }
                            self.lastGeocodedCheckpoint = location
                            if let start = self.startLocation {
                                self.distanceMeters = location.distance(
                                    from: start
                                )
                            }
                            let place = VisitedPlace.from(
                                placemarks.first,
                                coordinate: location.coordinate,
                                timestamp: Date()
                            )
                            self.visited.append(place)
                            #if DEBUG
                                self.dlog(
                                    "first-fix pin appended: \(place.title)"
                                )
                            #endif
                        }
                        .store(in: &self.bag.cancellables)
                }

                // Always publish the latest coordinate for the View to center on.
                self.currentCoordinate = location.coordinate
                if let last = self.lastCheckpoint {
                    let step = location.distance(from: last)
                    if step >= 20 {
                        self.lastCheckpoint = location
                        #if DEBUG
                            dlog(
                                "moved ≥20m (step=\(Int(step))) → will trigger geocode on cadence"
                            )
                        #endif
                        // Do not update distance here; we commit distance when we commit the pin.
                        self.movementSubject.send(location)
                    }
                }
            }
            .store(in: &bag.cancellables)

        // 2) Every 5s, if movement happened since last geocode, reverse-geocode
        timer
            .compactMap { [weak self] _ in
                self?.movementSubject.value as CLLocation?
            }
            .filter { [weak self] (loc: CLLocation) in
                guard let self else { return false }
                guard let lastGeo = self.lastGeocodedCheckpoint else {
                    return true
                }
                return loc.distance(from: lastGeo) >= 1
            }
            .flatMap {
                [weak self] (loc: CLLocation) -> AnyPublisher<
                    (CLLocation, [CLPlacemark]), Never
                > in
                guard let self else {
                    return Empty<(CLLocation, [CLPlacemark]), Never>()
                        .eraseToAnyPublisher()
                }
                #if DEBUG
                    dlog(
                        "geocoding @ lat=\(loc.coordinate.latitude), lon=\(loc.coordinate.longitude)"
                    )
                #endif
                return self.env.geocodingService
                    .reverseGeocode(location: loc)
                    .map { placemarks -> (CLLocation, [CLPlacemark]) in
                        (loc, placemarks)
                    }
                    .catch { [weak self] _ in
                        self?.alert = AlertState(
                            title: "Error",
                            message: AppError.geocodingFailed.userMessage
                        )
                        #if DEBUG
                            self?.dlog("geocoding failed → alert surfaced")
                        #endif
                        return Just((loc, [] as [CLPlacemark]))
                            .setFailureType(to: Never.self)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (loc: CLLocation, placemarks: [CLPlacemark]) in
                guard let self else { return }
                self.lastGeocodedCheckpoint = loc
                if let start = self.startLocation {
                    self.distanceMeters = loc.distance(from: start)
                }
                let place = VisitedPlace.from(
                    placemarks.first,
                    coordinate: loc.coordinate,
                    timestamp: Date()
                )
                self.visited.append(place)
                #if DEBUG
                    self.dlog(
                        "append visited (\(self.visited.count) total): \(place.title)"
                    )
                #endif
            }
            .store(in: &bag.cancellables)
    }

    public func stopTracking() {
        guard isTracking else { return }
        isTracking = false
        env.locationService.stopUpdates()
        // Cancel Combine pipelines (auth, locations, timer).
        bag.cancellables.removeAll()
        #if DEBUG
            dlog("stopTracking() — cancelled pipelines and stopped updates")
        #endif
    }

    public func select(place: VisitedPlace?) {
        selectedPlace = place
    }

    public func dismissAlert() {
        alert = nil
    }
}

// MARK: - AlertState (simple, UI-friendly)
public struct AlertState: Identifiable, Equatable {
    public let id = UUID()
    public var title: String
    public var message: String

    public init(title: String, message: String) {
        self.title = title
        self.message = message
    }
}
