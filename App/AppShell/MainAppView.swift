// App/AppShell/MainAppView.swift

import CoreLocation
import SwiftUI

struct MainAppView: View {
    let env: AppEnvironment
    @StateObject private var mapVM: MapTabViewModel

    @Environment(\.scenePhase) private var scenePhase
    @State private var permission: CLAuthorizationStatus = .notDetermined
    @State private var dismissedGateOnce = false

    init(env: AppEnvironment) {
        self.env = env
        _mapVM = StateObject(wrappedValue: MapTabViewModel(env: env))
    }

    var body: some View {
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
        // Observe permission status from the app-level service
        .onReceive(env.permissionService.locationStatus) { status in
            permission = status
        }
        // Start/stop on scene changes (only start when authorized)
        .onChange(of: scenePhase) { _, newPhase in
            #if DEBUG
                print(
                    "[MainAppView] scenePhase → \(String(describing: newPhase))"
                )
            #endif
            switch newPhase {
            case .active:
                if permission == .authorizedAlways
                    || permission == .authorizedWhenInUse
                {
                    mapVM.startTracking()
                }
            case .background:
                mapVM.stopTracking()
                // Show the gate again next session if still not authorized
                dismissedGateOnce = false
            default:
                break
            }
        }
        // Also react when permission flips while we're already active (after the Apple prompt)
        .onChange(of: permission) { _, newStatus in
            if scenePhase == .active {
                switch newStatus {
                case .authorizedAlways, .authorizedWhenInUse:
                    mapVM.startTracking()
                default:
                    mapVM.stopTracking()
                }
            }
        }
        // Permission gate overlay
        .overlay {
            switch permission {
            case .notDetermined where !dismissedGateOnce:
                OverlayCardView(title: "Allow Location While Using") {
                    dismissedGateOnce = true
                } content: {
                    VStack(spacing: 8) {
                        Text(
                            "We use your location (while the app is open) to drop pins every few seconds and compute distance. You’re in control, and you can change this anytime in Settings."
                        )
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        HStack {
                            Button("Not now") { dismissedGateOnce = true }
                            Spacer(minLength: 16)
                            Button("Allow While Using") {
                                env.permissionService.requestLocationWhenInUse()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }

            case .denied, .restricted:
                OverlayCardView(title: "Location Permission Needed") {
                    dismissedGateOnce = true
                } content: {
                    VStack(spacing: 8) {
                        Text(
                            "We can’t track your route without access to your location. You can enable it in Settings at any time."
                        )
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        HStack {
                            Button("Not now") { dismissedGateOnce = true }
                            Spacer(minLength: 16)
                            Button("Open Settings") {
                                env.permissionService.openSettings()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }

            default:
                EmptyView()
            }
        }
    }
}

#Preview {
    MainAppView(env: .live)
}
