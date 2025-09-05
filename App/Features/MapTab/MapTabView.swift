// App/MapTab/MapTabView.swift

import Combine
import MapKit
import SwiftUI

/// Map tab orchestrator: composes DistanceHeader, MapCanvas, and PlaceInfoOverlay.
/// Business logic stays in the VM.
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
    // Pin info overlay toggle
    @State private var showPlaceInfo = false

    var body: some View {
        VStack(spacing: 8) {
            DistanceHeaderView(meters: vm.distanceMeters)
            MapCanvasView(
                vm: vm,
                cameraPosition: $cameraPosition,
                region: $region,
                showPlaceInfo: $showPlaceInfo
            )
        }
        .onAppear { vm.startTracking() }
        // Error alert (permission/geocode)
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
        // Pin info overlay (tap outside to dismiss)
        .overlay {
            if showPlaceInfo, let place = vm.selectedPlace {
                PlaceInfoOverlayView(place: place) {
                    vm.select(place: nil)
                    showPlaceInfo = false
                }
            }
        }
        .padding(.top, 8)
        // Center the map on the first/next fix
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

#Preview { MainView(env: .live) }
