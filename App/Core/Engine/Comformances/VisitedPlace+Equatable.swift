// App/Core/Engine/Comformances/VisitedPlace+Equatable.swift

import CoreLocation

extension VisitedPlace {
    // Keep the exact semantics we had before (accuracy intentionally NOT part of ==).
    public static func == (lhs: VisitedPlace, rhs: VisitedPlace) -> Bool {
        lhs.id == rhs.id
            && lhs.coordinate.latitude == rhs.coordinate.latitude
            && lhs.coordinate.longitude == rhs.coordinate.longitude
            && lhs.timestamp == rhs.timestamp
            && lhs.title == rhs.title
            && lhs.subtitle == rhs.subtitle
    }
}
