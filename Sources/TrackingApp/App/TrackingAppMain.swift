import SwiftUI

@main
struct TrackingAppMain: App {
    @StateObject private var monitorService = AppMonitorService()
    @StateObject private var settings = AppSettings.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(monitorService)
                .environmentObject(settings)
                .preferredColorScheme(settings.colorScheme)
        }
        .defaultSize(width: 900, height: 600)
    }
}
