import SwiftUI
import Combine

struct TabRootView: View {
    @EnvironmentObject private var tint: EmberTint

    var body: some View {
        TabView {
            RoadsScreen()
                .tabItem {
                    Image(systemName: TrailGlyphs.roads)
                    Text("Roads")
                }

            TodayScreen()
                .tabItem {
                    Image(systemName: TrailGlyphs.today)
                    Text("Today")
                }

            JourneyScreen()
                .tabItem {
                    Image(systemName: TrailGlyphs.journey)
                    Text("Journey")
                }

            SettingsScreen()
                .tabItem {
                    Image(systemName: TrailGlyphs.settings)
                    Text("Settings")
                }
        }
        .accentColor(tint.primary)
        .background(tint.background.ignoresSafeArea())
    }
}
