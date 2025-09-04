// App/MapTab/MapTabView.swift

import Combine
import MapKit
import SwiftUI

/// Map tab: shows user location, distance label, dropped pins from `[VisitedPlace]`,
/// and handles tap → info alert. Starts tracking on appear.
/// iOS 17+: uses MapContentBuilder + Annotation
/// iOS 16:  falls back to legacy Map(coordinateRegion:) + MapAnnotation
struct MapTabView: View {
    @ObservedObject var vm: MapTabViewModel

    private static let initialRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 60, longitudeDelta: 60)
    )

    // iOS 17 camera (primary path)
    @State private var cameraPosition: MapCameraPosition = .region(
        Self.initialRegion
    )
    // iOS 16 region (fallback)
    @State private var region: MKCoordinateRegion = Self.initialRegion

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

            // Map (iOS 17+) with content builder + Annotation
            if #available(iOS 17, *) {
                Map(position: $cameraPosition) {
                    // Show user's location (blue dot)
                    UserAnnotation()

                    // Pins for visited places
                    ForEach(vm.visited) { place in
                        Annotation(place.title, coordinate: place.coordinate) {
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
                }
                .ignoresSafeArea(edges: .bottom)
            } else {
                // iOS 16 fallback: legacy Map API (deprecated in iOS 17, but fine here)
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
                .ignoresSafeArea(edges: .bottom)
            }
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
        // Center the map when we get the first/next real fix
        .onReceive(vm.$currentCoordinate.compactMap { $0 }) { coord in
            let tight = MKCoordinateSpan(
                latitudeDelta: 0.01,
                longitudeDelta: 0.01
            )
            cameraPosition = .region(.init(center: coord, span: tight))  // iOS 17 path
            region = .init(center: coord, span: tight)  // iOS 16 fallback
        }
    }
}

#Preview {
    MainView(env: .live)
}
