// App/Core/AppFeatures/MapTabScreen/Components/MapCanvasView.swift

import MapKit
import SwiftUI

/// Hosts the Map UI for both iOS 17+ (MapContentBuilder) and iOS 16 (legacy Map).
struct MapCanvasView: View {
    @ObservedObject var vm: MapViewModel
    @Binding var cameraPosition: MapCameraPosition
    @Binding var region: MKCoordinateRegion
    @Binding var showPlaceInfo: Bool

    var body: some View {
        canvasView
    }

    var canvasView: some View {
        Group {
            if #available(iOS 17, *) {
                Map(position: $cameraPosition) {
                    UserAnnotation()
                    ForEach(vm.visitedPlacesList) { place in
                        Annotation(place.title, coordinate: place.coordinate) {
                            Button {
                                vm.select(place: place)
                                showPlaceInfo = true
                            } label: {
                                Image(systemName: "mappin.and.ellipse")
                                    .symbolRenderingMode(.monochrome)
                                    .foregroundStyle(.red)
                                    .imageScale(.large)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(Text(place.title))
                        }
                    }
                }
            } else {
                /// Fallback
                Map(
                    coordinateRegion: $region,
                    showsUserLocation: true,
                    annotationItems: vm.visitedPlacesList
                ) { place in
                    MapAnnotation(coordinate: place.coordinate) {
                        Button {
                            vm.select(place: place)
                            showPlaceInfo = true
                        } label: {
                            Image(systemName: "mappin.and.ellipse")
                                .symbolRenderingMode(.monochrome)
                                .foregroundStyle(.red)
                                .imageScale(.large)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text(place.title))
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
