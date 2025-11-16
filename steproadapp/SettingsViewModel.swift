import SwiftUI
import Combine

final class SettingsViewModel: ObservableObject {
    @Published var isShowingPrivacy: Bool = false
    @Published var selectedThemeStyle: String = "ember"
    @Published var intensityPreviewText: String = FormatKit.fireIntensityText(1.0)

    // MARK: - Sync

    func sync(from config: FireConfigStore) {
        selectedThemeStyle = config.themeStyle
        intensityPreviewText = FormatKit.fireIntensityText(config.fireIntensity)
    }

    // MARK: - Theme

    func updateThemeStyle(_ style: String, in config: FireConfigStore) {
        config.themeStyle = style
        selectedThemeStyle = style
    }

    // MARK: - Fire intensity

    func updateIntensity(_ value: Double, in config: FireConfigStore) {
        config.fireIntensity = value
        intensityPreviewText = FormatKit.fireIntensityText(value)
    }

    // MARK: - Haptics

    func setHapticsEnabled(_ isOn: Bool, in config: FireConfigStore) {
        config.isHapticsEnabled = isOn
        if isOn {
            EmberHaptics.shared.spark()
        }
    }

    // MARK: - Reset hour

    func setResetHour(_ hour: Int, in config: FireConfigStore) {
        let clamped = max(0, min(23, hour))
        config.resetHour = clamped
    }

    // MARK: - Notifications flag

    func setNotificationsEnabled(_ isOn: Bool, in config: FireConfigStore) {
        config.notificationsEnabled = isOn
    }

    // MARK: - Privacy

    func showPrivacy() {
        isShowingPrivacy = true
    }

    func hidePrivacy() {
        isShowingPrivacy = false
    }

    func privacyUrl(from config: FireConfigStore) -> URL {
        config.privacyUrl
    }
}
