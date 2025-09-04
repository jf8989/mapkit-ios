// App/PlacesTab/PlacesTabView.swift
import SwiftUI

/// Placeholder for the Places list tab.
/// Phase 0: Static list; later phases will consume `[VisitedPlace]` from VM.
struct PlacesTabView: View {
    var body: some View {
        List {
            Section("Visited") {
                Text("No places yet.")
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.insetGrouped)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { PlacesTabView() }
}
