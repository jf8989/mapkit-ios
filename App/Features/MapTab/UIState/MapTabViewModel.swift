// App/MapTab/UIState/MapTabViewModel.swift

import Combine
import CoreLocation
import Foundation

/// ViewModel for the Map tab.
/// Responsibilities:
/// - Own location streams (via LocationServiceType)
/// - Compute total distance from the initial fix
/// - Emit a "moved ≥ 20 m" event
/// - Every 5s, if movement occurred, reverse-geocode and append a VisitedPlace
/// - Surface simple alert state (title/message)
@MainActor
public final class MapTabViewModel: ObservableObject {
    // Inputs
    private let env: AppEnvironment
    private let bag = TaskBag()

    // UI state
    @Published public private(set) var distanceMeters: Double = 0
    @Published public private(set) var visited: [VisitedPlace] = []
    /// Latest known coordinate (nil until we get a real fix). View uses this to center the map.
    @Published public private(set) var currentCoordinate:
        CLLocationCoordinate2D?
    @Published public var alert: AlertState?

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
    }

    // MARK: - Intents

    public func startTracking() {
        // Idempotent guard: avoid double subscriptions.
        if isTracking { return }
        isTracking = true

        // Ask once; then react to authorization stream for actual start/stop.
        env.locationService.requestWhenInUseAuthorization()

        // React to permission changes (includes the current value on subscribe).
        env.locationService.authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .authorizedAlways, .authorizedWhenInUse:
                    self.env.locationService.startUpdates()
                case .denied, .restricted:
                    self.env.locationService.stopUpdates()
                    self.alert = AlertState(
                        title: "Location Permission",
                        message: AppError.notAuthorized.userMessage
                    )
                case .notDetermined:
                    // Keep waiting; system will prompt.
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
                }
                // Always publish the latest coordinate for the View to center on.
                self.currentCoordinate = location.coordinate

                if let last = self.lastCheckpoint {
                    let step = location.distance(from: last)
                    if step >= 20 {
                        self.lastCheckpoint = location
                        // Total distance from the initial fix
                        if let start = self.startLocation {
                            self.distanceMeters = location.distance(from: start)
                        }
                        self.movementSubject.send(location)
                    }
                }
            }
            .store(in: &bag.cancellables)

        // 2) Every 5s, if movement happened since last geocode, reverse-geocode
        timer
            .compactMap { [weak self] _ in
                self?.movementSubject.value as CLLocation?
            }  // be explicit
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
                        // Return a typed value to keep the stream shape
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
                let place = VisitedPlace.from(
                    placemarks.first,
                    coordinate: loc.coordinate,
                    timestamp: Date()
                )
                self.visited.append(place)
            }
            .store(in: &bag.cancellables)
    }

    public func stopTracking() {
        guard isTracking else { return }
        isTracking = false
        env.locationService.stopUpdates()
        // Cancel Combine pipelines (auth, locations, timer).
        bag.cancellables.removeAll()
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
