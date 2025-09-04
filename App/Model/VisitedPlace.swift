// App/Model/VisitedPlace.swift

import CoreLocation

/// Minimal domain model for a visited location.
/// Phase 3 may extend display fields and formatting.
public struct VisitedPlace: Identifiable, Equatable {
    public let id: UUID
    public let coordinate: CLLocationCoordinate2D
    public let timestamp: Date
    public let title: String
    public let subtitle: String

    public init(
        id: UUID = UUID(),
        coordinate: CLLocationCoordinate2D,
        timestamp: Date,
        title: String,
        subtitle: String
    ) {
        self.id = id
        self.coordinate = coordinate
        self.timestamp = timestamp
        self.title = title
        self.subtitle = subtitle
    }

    public static func == (lhs: VisitedPlace, rhs: VisitedPlace) -> Bool {
        lhs.id == rhs.id && lhs.coordinate.latitude == rhs.coordinate.latitude
            && lhs.coordinate.longitude == rhs.coordinate.longitude
            && lhs.timestamp == rhs.timestamp && lhs.title == rhs.title
            && lhs.subtitle == rhs.subtitle
    }

    // Factory used by VM after reverse-geocoding
    public static func from(
        _ placemark: CLPlacemark?,
        coordinate: CLLocationCoordinate2D,
        timestamp: Date
    ) -> VisitedPlace {
        let title = placemark?.name ?? placemark?.locality ?? "Dropped Pin"
        let subtitle = [
            placemark?.locality, placemark?.administrativeArea,
            placemark?.country,
        ]
        .compactMap { $0 }
        .joined(separator: ", ")
        return .init(
            coordinate: coordinate,
            timestamp: timestamp,
            title: title,
            subtitle: subtitle
        )
    }
}
