// App/Engine/Services/LocationService.swift

import Combine
import CoreLocation

/// Live implementation of LocationServiceType using a delegate bridge and Combine.
/// Notes:
/// - No async/await per assignment.
/// - Consumers handle back-pressure (20m gate etc.).
public final class LocationService: NSObject, LocationServiceType {
    private let manager = CLLocationManager()
    private let bridge = LocationManagerDelegateBridge()

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

        bridge.locationSubject
            .sink { [weak self] in self?.locationSubject.send($0) }
            .store(in: &cancellables)

        bridge.authSubject
            .sink { [weak self] in self?.authSubject.send($0) }
            .store(in: &cancellables)

        // If the delegate emits a failure, we currently just drop it.
        // VM maps geocoding errors to UI; location manager errors here are rare.
        bridge.errorSubject
            .sink { _ in /* log lane if needed */ }
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
