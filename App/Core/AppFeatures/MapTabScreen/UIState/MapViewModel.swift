// App/Core/AppFeatures/MapTabScreen/UIState/MapViewModel.swift

import Combine
import CoreLocation
import Foundation

@MainActor
public final class MapViewModel: ObservableObject {
    /// Inputs
    let env: AppEnvironment
    let bag = TaskBag()
    private var permissionRequested = false

    /// UI state
    @Published public var distanceMeters: Double = 0
    @Published public var visitedPlacesList: [VisitedPlace] = []
    /// Latest known coordinate (nil until we get a real fix). View uses this to center the map.
    @Published public private(set) var currentCoordinate:
        CLLocationCoordinate2D?
    @Published public var alert: AlertState?

    /// Permission gate for Location (nil = authorized / no gate)
    @Published public private(set) var permissionGate: LocationPermissionGate?

    /// Selection (for pin tap later)
    @Published public var selectedPlace: VisitedPlace?

    /// Internals
    private var isTracking = false
    var startLocation: CLLocation?
    var lastCheckpoint: CLLocation?
    var lastGeocodedCheckpoint: CLLocation?

    /// Movement signal (emits when we pass the 20 m gate)
    private let movementSubject = CurrentValueSubject<CLLocation?, Never>(nil)

    /// 5-second cadence
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

        // 0) Permission flow — manager-as-router (request once; show gate only when denied)
        env.permissionAPI.locationGate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                switch state {
                case .authorized:
                    self.permissionGate = nil
                case .needsRequest:
                    if !self.permissionRequested {
                        self.permissionRequested = true
                        self.env.permissionAPI.requestLocationPermission()
                    }
                case .needsSettings:
                    self.permissionGate = .needsSettings
                }
            }
            .store(in: &bag.cancellables)

        // React to authorization changes (includes the current value on subscribe).
        env.locationAPI.authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .authorizedAlways, .authorizedWhenInUse:
                    self.env.locationAPI.startUpdates()
                case .denied, .restricted:
                    self.env.locationAPI.stopUpdates()
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

        // Location manager errors → alert (except transient “location unknown”).
        env.locationAPI.errors
            .receive(on: DispatchQueue.main)
            .sink { [weak self] err in
                guard let self else { return }
                if let clErr = err as? CLError, clErr.code == .locationUnknown {
                    // Transient; ignore and let the next fix arrive.
                    return
                }
                self.alert = AlertState(
                    title: "Location Error",
                    message: AppError.geocodingFailed.userMessage  // reuse copy; or introduce a new message if you prefer
                )
            }
            .store(in: &bag.cancellables)

        // 1) Process raw locations → 20m gate
        env.locationAPI.locationUpdates
            .receive(on: DispatchQueue.main)  // UI updates on main
            .sink { [weak self] location in
                guard let self else { return }

                if self.startLocation == nil {
                    self.handleFirstFix(location: location)
                }

                // Always publish the latest coordinate for the View to center on.
                self.currentCoordinate = location.coordinate

                if let last = self.lastCheckpoint {
                    let step = location.distance(from: last)
                    if step >= 20 {
                        self.lastCheckpoint = location
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
                    (CLLocation, VisitedPlace?), Never
                > in
                guard let self else {
                    return Empty<(CLLocation, VisitedPlace?), Never>()
                        .eraseToAnyPublisher()
                }
                return geocodeVisitedPlace(
                    self.env.geocodingAPI,
                    for: loc,
                    now: Date()
                )
                .map { (loc, Optional($0)) }
                .catch { [weak self] _ in
                    self?.handleGeocodeError()
                    return Just<(CLLocation, VisitedPlace?)>((loc, nil))
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (loc: CLLocation, place: VisitedPlace?) in
                guard let self else { return }
                self.commitPinAndDistance(at: loc, place: place)
            }
            .store(in: &bag.cancellables)
    }

    public func stopTracking() {
        guard isTracking else { return }
        isTracking = false
        env.locationAPI.stopUpdates()
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
