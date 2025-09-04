// App/Main/MainView.swift
import SwiftUI

struct MainView: View {
    let env: AppEnvironment
    @StateObject private var mapVM: MapTabViewModel

    init(env: AppEnvironment) {
        self.env = env
        _mapVM = StateObject(wrappedValue: MapTabViewModel(env: env))
    }

    var body: some View {
        TabView {
            NavigationStack {
                MapTabView(vm: mapVM)
                    .navigationTitle("Map")
            }
            .tabItem {
                Image(systemName: "map")
                Text("Map")
            }

            NavigationStack {
                PlacesTabView(vm: mapVM)
                    .navigationTitle("Places")
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Places")
            }
        }
    }
}

#Preview {
    MainView(env: .live)
}
