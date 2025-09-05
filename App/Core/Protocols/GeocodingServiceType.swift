// App/Protocols/GeocodingServiceType.swift

import Combine
import CoreLocation

/// Contract for reverse-geocoding with Combine (no async/await).
public protocol GeocodingServiceType {
    func reverseGeocode(location: CLLocation) -> AnyPublisher<
        [CLPlacemark], Error
    >
}
