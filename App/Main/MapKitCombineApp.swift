// App/Main/MapKitCombineApp.swift

import SwiftUI

/// Entry point for the MapKit + Combine assignment app.
/// Root composes `MainView` only; no business logic here.
@main
struct MapKitCombineApp: App {
    private let env = AppEnvironment.live

    var body: some Scene {
        WindowGroup {
            MainView(env: env)
        }
    }
}
