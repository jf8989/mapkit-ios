// App/Engine/GeocodingService.swift

import Combine
import CoreLocation

/// Reverse-geocoder wrapped in Combine.
/// Uses a serial queue to avoid blocking the main thread.
public final class GeocodingService: GeocodingServiceType {
    private let geocoder = CLGeocoder()
    private let queue = DispatchQueue(label: "GeocodingService.queue")

    public init() {}

    public func reverseGeocode(location: CLLocation) -> AnyPublisher<
        [CLPlacemark], Error
    > {
        Future<[CLPlacemark], Error> { [weak self] promise in
            guard let self else { return }
            self.queue.async {
                self.geocoder.reverseGeocodeLocation(location) {
                    placemarks,
                    error in
                    if let error {
                        promise(.failure(error))
                    } else {
                        promise(.success(placemarks ?? []))
                    }
                }
            }
        }
        // Subscribers decide where to receive; we don't force main here.
        .eraseToAnyPublisher()
    }
}
