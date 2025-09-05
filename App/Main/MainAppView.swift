// App/Main/MainView.swift
import SwiftUI

struct MainAppView: View {
    let env: AppEnvironment
    @StateObject private var mapVM: MapTabViewModel

    init(env: AppEnvironment) {
        self.env = env
        _mapVM = StateObject(wrappedValue: MapTabViewModel(env: env))
    }

    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        mapAndPlacesViews
            .onChange(of: scenePhase) { newPhase in
                switch newPhase {
                case .active:
                    mapVM.startTracking()
                case .background:
                    mapVM.stopTracking()
                default:
                    break
                }
            }
            .task { mapVM.startTracking() }  // kick on first launch
    }

    var mapAndPlacesViews: some View {
        TabView {
            NavigationStack {
                MapTabView(vm: mapVM)
                    .navigationTitle("Tracker")
            }
            .tabItem {
                Image(systemName: "map")
                Text("Map")
            }

            NavigationStack {
                PlacesTabView(vm: mapVM)
                    .navigationTitle("My Places")
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Places")
            }
        }
    }
}

#Preview {
    MainAppView(env: .live)
}
