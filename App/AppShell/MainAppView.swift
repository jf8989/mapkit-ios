// App/AppShell/MainAppView.swift

import SwiftUI

struct MainAppView: View {
    let env: AppEnvironment
    @StateObject private var mapVM: MapTabViewModel
    @Environment(\.scenePhase) private var scenePhase

    init(env: AppEnvironment) {
        self.env = env
        _mapVM = StateObject(wrappedValue: MapTabViewModel(env: env))
    }

    var body: some View { Content() }

    // MARK: - Subviews

    @ViewBuilder private func Content() -> some View {
        TabView {
            NavigationStack {
                MapTabView(vm: mapVM)
                    .navigationTitle("Tracker")
            }
            .tabItem { Label("Map", systemImage: "map") }

            NavigationStack {
                PlacesTabView(vm: mapVM)
                    .navigationTitle("My Places")
            }
            .tabItem { Label("Places", systemImage: "list.bullet") }
        }
        // App-level lifecycle: start on active, stop on background
        .onChange(of: scenePhase) { _, newPhase in
            #if DEBUG
                print(
                    "[MainAppView] scenePhase → \(String(describing: newPhase))"
                )
            #endif
            switch newPhase {
            case .active:
                mapVM.startTracking()
            case .background:
                mapVM.stopTracking()
            default:
                break
            }
        }
        // Kick once on first launch (idempotent in VM)
        .task { mapVM.startTracking() }
    }
}

#Preview { MainAppView(env: .live) }
