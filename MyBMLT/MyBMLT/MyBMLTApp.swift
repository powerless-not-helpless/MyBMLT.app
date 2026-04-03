import SwiftUI

@main
struct MyBMLTApp: App {
    @StateObject private var locationService = LocationService()

    var body: some Scene {
        WindowGroup("BMLT 2026 v1") {
            ContentView()
                .environmentObject(locationService)
        }
    }
}
