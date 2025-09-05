// App/PlacesTab/PlacesTabView.swift
import SwiftUI

/// Places tab: reads `[VisitedPlace]` from shared VM and lists them.
struct PlacesTabView: View {
    @ObservedObject var vm: MapTabViewModel

    var body: some View {
        placesView
    }

    var placesView: some View {
        List {
            Section("Visited") {
                if vm.visited.isEmpty {
                    Text("No places yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(
                        vm.visited.sorted(by: { $0.timestamp > $1.timestamp })
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
                        // Hint a preferred transition when inserted at the top.
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        // Smooth animation when count changes (new item at top).
        .animation(
            .spring(response: 0.35, dampingFraction: 0.9, blendDuration: 0.15),
            value: vm.visited.count
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MainAppView(env: .live)
}
