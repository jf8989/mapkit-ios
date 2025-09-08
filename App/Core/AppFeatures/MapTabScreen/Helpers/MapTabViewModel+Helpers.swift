// App/Core/AppFeatures/MapTabScreen/Helpers/MapTabViewModel+Helpers.swift

import Combine
import CoreLocation
import Foundation

extension MapViewModel {
    // MARK: - Extracted helpers

    /// First authorized GPS fix: seed start/checkpoints and perform one-shot geocode.
    func handleFirstFix(location: CLLocation) {
        self.startLocation = location
        self.lastCheckpoint = location

        geocodeVisitedPlace(
            self.env.geocodingAPI,
            for: location,
            now: Date()
        )
        .catch { [weak self] _ -> Empty<VisitedPlace, Never> in
            self?.handleGeocodeError()
            return Empty()
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] place in
            guard let self else { return }
            self.commitPinAndDistance(at: location, place: place)
        }
        .store(in: &self.bag.cancellables)
    }

    /// Single point of truth for updating distance, checkpoint, and appending place.
    func commitPinAndDistance(at loc: CLLocation, place: VisitedPlace?) {
        self.lastGeocodedCheckpoint = loc
        if let start = self.startLocation {
            self.distanceMeters = loc.distance(from: start)
        }
        if let place {
            self.visitedPlacesList.append(place)
        }
    }

    /// Reverse-geocodes a CLLocation into a VisitedPlace.
    /// Does not hop threads; caller decides receive(on:).
    public func geocodeVisitedPlace(
        _ geocoder: GeocodingServiceType,
        for location: CLLocation,
        now: @autoclosure @escaping () -> Date = Date()
    ) -> AnyPublisher<VisitedPlace, Error> {
        geocoder
            .reverseGeocode(location: location)
            .map { placemarks in
                let acc = location.horizontalAccuracy
                let safeAcc: CLLocationAccuracy? = acc >= 0 ? acc : nil
                return VisitedPlaceFactory.make(
                    from: placemarks.first,
                    coordinate: location.coordinate,
                    timestamp: now(),
                    horizontalAccuracy: safeAcc
                )
            }
            .eraseToAnyPublisher()
    }

    /// Shared UI error mapping for geocoding failures.
    func handleGeocodeError() {
        self.alert = AlertState(
            title: "Error",
            message: AppError.geocodingFailed.userMessage
        )
    }
}
