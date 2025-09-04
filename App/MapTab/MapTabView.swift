// App/MapTab/MapTabView.swift
import SwiftUI

/// Placeholder for the Map tab.
/// Phase 0: No MapKit/Combine logic—just a minimal layout stub.
/// Phase 2/3 will bind distance label, pins, and alerts to the VM.
struct MapTabView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Map will appear here.")
                .font(.headline)

            // Placeholder distance label (will bind to VM later)
            HStack {
                Text("Distance:")
                    .font(.subheadline)
                Text("— m")
                    .monospacedDigit()
                    .accessibilityLabel("Distance in meters")
            }
            .padding(.horizontal)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
    }
}

#Preview {
    MapTabView()
}
