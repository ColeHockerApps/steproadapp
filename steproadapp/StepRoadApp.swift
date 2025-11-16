import SwiftUI
import Combine

@main
struct StepRoadApp: App {
    @StateObject private var tint = EmberTint()
    @StateObject private var vault = TrailVault()
    @StateObject private var config = FireConfigStore()

    @StateObject private var roadsVM = RoadsViewModel()
    @StateObject private var todayVM = TodayViewModel()
    @StateObject private var journeyVM = JourneyViewModel()
    @StateObject private var settingsVM = SettingsViewModel()

    var body: some Scene {
        WindowGroup {
            TabRootView()
                .environmentObject(tint)
                .environmentObject(vault)
                .environmentObject(config)
                .environmentObject(roadsVM)
                .environmentObject(todayVM)
                .environmentObject(journeyVM)
                .environmentObject(settingsVM)
        }
    }
}
