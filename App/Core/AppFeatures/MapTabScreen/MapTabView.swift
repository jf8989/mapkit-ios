// App/Core/AppFeatures/MapTabScreen/MapTabView.swift

import MapKit
import SwiftUI

/// Map tab orchestrator: composes DistanceHeader, MapCanvas, and overlays.
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
    // Overlays
    @State private var showPlaceInfo = false
    @State private var showPermissionGate = false

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
        // Error alert (geocode/permission)
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

        // Permission gate overlay — shown only when user previously denied/restricted
        .overlay {
            if showPermissionGate, vm.gate == .needsSettings {
                OverlayCardView(title: "Location Permission") {
                    // Outside tap dismiss; overlay will reappear until user authorizes in Settings later
                    showPermissionGate = false
                } content: {
                    VStack(spacing: 8) {
                        Text(
                            "We can’t track your route without access to your location. If you change your mind later, go to Settings → Privacy & Security → Location Services and grant access while using the app."
                        )
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        Button("OK") {
                            // Per product decision, no deep link; just dismiss.
                            showPermissionGate = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .onTapGesture { showPermissionGate = false }
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

        // Drive permission overlay visibility from VM gate
        .onChange(of: vm.gate) { _, newGate in
            showPermissionGate = (newGate == .needsSettings)
        }
    }
}

#Preview { MainAppView(env: .live) }
