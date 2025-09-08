// App/Main/MapKitCombineApp.swift

import SwiftUI

@main
struct MapKitCombineApp: App {
    private let env = AppEnvironment.live

    var body: some Scene {
        WindowGroup {
            MainAppView(env: env)
        }
    }
}
