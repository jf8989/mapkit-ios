// App/MapTab/Components/MapCanvasView.swift

import MapKit
import SwiftUI

/// Hosts the Map UI for both iOS 17+ (MapContentBuilder) and iOS 16 (legacy Map).
struct MapCanvas: View {
    @ObservedObject var vm: MapTabViewModel
    @Binding var cameraPosition: MapCameraPosition
    @Binding var region: MKCoordinateRegion
    @Binding var showPlaceInfo: Bool

    var body: some View {
        Group {
            if #available(iOS 17, *) {
                Map(position: $cameraPosition) {
                    UserAnnotation()
                    ForEach(vm.visited) { place in
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
