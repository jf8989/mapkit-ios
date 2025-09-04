// App/Engine/LocationManagerDelegateBridge.swift

import Combine
import CoreLocation

/// Classic delegate → Combine bridge for CLLocationManager.
/// Emits auth changes, new locations, and errors.
final class LocationManagerDelegateBridge: NSObject, CLLocationManagerDelegate {
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
