// App/Protocols/LocationServiceType.swift

import Combine
import CoreLocation

/// Contract for location/authorization streams (Combine-only).
public protocol LocationServiceType {
    var authorizationStatus: AnyPublisher<CLAuthorizationStatus, Never> { get }
    var locationUpdates: AnyPublisher<CLLocation, Never> { get }
    var errors: AnyPublisher<Error, Never> { get }

    func requestWhenInUseAuthorization()
    func startUpdates()
    func stopUpdates()
}
