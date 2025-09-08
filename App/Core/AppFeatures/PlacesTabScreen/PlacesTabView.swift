// App/PlacesTab/PlacesTabView.swift
import SwiftUI

struct PlacesTabView: View {
    @ObservedObject var vm: MapViewModel

    var body: some View {
        placesView
    }

    var placesView: some View {
        List {
            Section("Visited") {
                if vm.visitedPlacesList.isEmpty {
                    Text("No places yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(
                        vm.visitedPlacesList.sorted(by: { $0.timestamp > $1.timestamp })
                    ) { place in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(place.title).font(.body.weight(.semibold))
                            if !place.subtitle.isEmpty {
                                Text(place.subtitle).font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            Text(
                                place.timestamp.formatted(
                                    date: .abbreviated,
                                    time: .shortened
                                )
                            )
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        // Smooth animation when count changes (new item at top).
        .animation(
            .spring(response: 0.35, dampingFraction: 0.9, blendDuration: 0.15),
            value: vm.visitedPlacesList.count
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MainAppView(env: .live)
}
