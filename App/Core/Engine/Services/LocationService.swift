// App/Engine/Services/LocationService.swift

import Combine
import CoreLocation

/// Live implementation of LocationServiceType using a delegate bridge and Combine.
public final class LocationService: NSObject, LocationServiceType {
    private let manager = CLLocationManager()
    private let bridge = DelegateBridge()

    private let locationSubject = PassthroughSubject<CLLocation, Never>()
    private let authSubject = CurrentValueSubject<CLAuthorizationStatus, Never>(
        .notDetermined
    )

    private var cancellables = Set<AnyCancellable>()

    public override init() {
        super.init()
        manager.delegate = bridge
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.pausesLocationUpdatesAutomatically = true

        // Publish current status immediately so subscribers react on first subscribe.
        authSubject.send(manager.authorizationStatus)

        bridge.locationSubject
            .sink { [weak self] in self?.locationSubject.send($0) }
            .store(in: &cancellables)

        bridge.authSubject
            .sink { [weak self] in self?.authSubject.send($0) }
            .store(in: &cancellables)
    }

    // MARK: - LocationServiceType

    public var authorizationStatus: AnyPublisher<CLAuthorizationStatus, Never> {
        authSubject.eraseToAnyPublisher()
    }
    public var locationUpdates: AnyPublisher<CLLocation, Never> {
        locationSubject.eraseToAnyPublisher()
    }

    public func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    public func startUpdates() {
        manager.startUpdatingLocation()
    }

    public func stopUpdates() {
        manager.stopUpdatingLocation()
    }
}

// MARK: - Private delegate bridge
private final class DelegateBridge: NSObject, CLLocationManagerDelegate {
    let authSubject = PassthroughSubject<CLAuthorizationStatus, Never>()
    let locationSubject = PassthroughSubject<CLLocation, Never>()
    let errorSubject = PassthroughSubject<Error, Never>()

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authSubject.send(manager.authorizationStatus)
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        locations.forEach { locationSubject.send($0) }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        errorSubject.send(error)
    }
}
