// App/MapTab/Components/PlaceInfoOverlayView.swift

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
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 12) {
                Text("Location Info").font(.headline)
                Text(details)
                    .multilineTextAlignment(.center)

                Button("OK") { onDismiss() }
                    .buttonStyle(.borderedProminent)
            }
            .padding(16)
            .frame(maxWidth: 320)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .shadow(radius: 10)
        }
        .transition(.opacity.combined(with: .scale))
        .animation(.easeOut(duration: 0.2), value: place.id)
    }

    private var details: String {
        let lat = place.coordinate.latitude
        let lon = place.coordinate.longitude
        let when = place.timestamp.formatted(
            date: .abbreviated,
            time: .shortened
        )
        return """
            \(place.title)
            \(place.subtitle)
            Lat \(String(format: "%.5f", lat)), Lon \(String(format: "%.5f", lon))
            \(when)
            """
    }
}
