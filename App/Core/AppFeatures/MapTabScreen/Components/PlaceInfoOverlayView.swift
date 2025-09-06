// App/Core/AppFeatures/MapTabScreen/Components/PlaceInfoOverlayView.swift

import CoreLocation
import SwiftUI

/// Lightweight card that dismisses on outside tap or OK.
struct PlaceInfoOverlayView: View {
    let place: VisitedPlace
    let onDismiss: () -> Void

    var body: some View {
        placeInfoView
    }

    var placeInfoView: some View {
        OverlayCardView(title: "Location Info", onDismiss: onDismiss) {
            Text(details)
                .multilineTextAlignment(.center)
        }
        .animation(.easeOut(duration: 0.2), value: place.id)
    }

    private var details: String {
        let lat = place.coordinate.latitude
        let lon = place.coordinate.longitude
        let when = place.timestamp.formatted(
            date: .abbreviated,
            time: .shortened
        )

        var lines: [String] = [
            place.title,
            place.subtitle,
            "Lat \(String(format: "%.5f", lat)), Lon \(String(format: "%.5f", lon))",
        ]

        if let acc = place.horizontalAccuracy {
            lines.append("Accuracy \(Int(acc)) m")
        }

        lines.append(when)
        return lines.joined(separator: "\n")
    }
}
