// App/Model/VisitedPlace.swift

import CoreLocation

public struct VisitedPlace: Identifiable, Equatable {
    public let id: UUID
    public let coordinate: CLLocationCoordinate2D
    public let timestamp: Date
    public let title: String
    public let subtitle: String
    public let horizontalAccuracy: CLLocationAccuracy?

    public init(
        id: UUID = UUID(),
        coordinate: CLLocationCoordinate2D,
        timestamp: Date,
        title: String,
        subtitle: String,
        horizontalAccuracy: CLLocationAccuracy? = nil
    ) {
        self.id = id
        self.coordinate = coordinate
        self.timestamp = timestamp
        self.title = title
        self.subtitle = subtitle
        self.horizontalAccuracy = horizontalAccuracy
    }
}
