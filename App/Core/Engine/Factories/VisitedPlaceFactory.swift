// App/Core/Engine/Factories/VisitedPlaceFactory.swift

import CoreLocation

public enum VisitedPlaceFactory {
    /// Builds a VisitedPlace from an optional placemark and known location pieces.
    public static func make(
        from placemark: CLPlacemark?,
        coordinate: CLLocationCoordinate2D,
        timestamp: Date,
        horizontalAccuracy: CLLocationAccuracy? = nil
    ) -> VisitedPlace {
        let title = placemark?.name ?? placemark?.locality ?? "Dropped Pin"
        let subtitle = [
            placemark?.locality,
            placemark?.administrativeArea,
            placemark?.country,
        ]
        .compactMap { $0 }
        .joined(separator: ", ")

        return VisitedPlace(
            coordinate: coordinate,
            timestamp: timestamp,
            title: title,
            subtitle: subtitle,
            horizontalAccuracy: horizontalAccuracy
        )
    }
}
