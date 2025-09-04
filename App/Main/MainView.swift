// File: /App/Main/MainView.swift
import SwiftUI

/// Root shell: TabView with each tab hosted inside its own NavigationStack.
/// Navigation guardrails:
/// - Separate back stacks per tab
/// - Value-based destinations only (added in later phases)
/// - No custom Binding(get:set:) to VM state
struct MainView: View {
    var body: some View {
        TabView {
            NavigationStack {
                MapTabView()
                    .navigationTitle("Map")
            }
            .tabItem {
                Image(systemName: "map")
                Text("Map")
            }

            NavigationStack {
                PlacesTabView()
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
    MainView()
}
