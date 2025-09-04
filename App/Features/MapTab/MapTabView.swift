// App/MapTab/MapTabView.swift

import MapKit
import SwiftUI

/// Map tab: shows user location, distance label, dropped pins from `[VisitedPlace]`,
/// and handles tap → info alert. Starts tracking on appear.
struct MapTabView: View {
    @ObservedObject var vm: MapTabViewModel

    // World-ish default; camera will stay wide until user moves.
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 60, longitudeDelta: 60)
    )

    // Separate alert for pin info (VM also exposes error alert)
    @State private var showPlaceInfo = false

    var body: some View {
        VStack(spacing: 8) {
            // Distance label
            HStack(spacing: 6) {
                Text("Distance:")
                    .font(.subheadline)
                Text(
                    vm.distanceMeters,
                    format: .number.precision(.fractionLength(0))
                )
                .monospacedDigit()
                .font(.subheadline.weight(.semibold))
                Text("m").font(.footnote)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            // Map with user location + pins
            Map(
                coordinateRegion: $region,
                showsUserLocation: true,
                annotationItems: vm.visited
            ) { place in
                MapAnnotation(coordinate: place.coordinate) {
                    Button {
                        vm.select(place: place)
                        showPlaceInfo = true
                    } label: {
                        Image(systemName: "mappin.circle.fill")
                            .imageScale(.large)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text(place.title))
                }
            }
            .mapStyle(.standard)
            .ignoresSafeArea(edges: .bottom)
        }
        .onAppear { vm.startTracking() }
        // Geocoder/user error alert
        .alert(item: $vm.alert) { state in
            Alert(
                title: Text(state.title),
                message: Text(state.message),
                dismissButton: .default(
                    Text("OK"),
                    action: { vm.dismissAlert() }
                )
            )
        }
        // Pin info alert
        .alert(
            "Location Info",
            isPresented: $showPlaceInfo,
            presenting: vm.selectedPlace
        ) { _ in
            Button("OK") { vm.select(place: nil) }
        } message: { place in
            Text("\(place.title)\n\(place.subtitle)")
        }
        .padding(.top, 8)
    }
}

#Preview {
    MainView(env: .live)
}
