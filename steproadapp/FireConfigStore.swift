import SwiftUI
import Combine

private struct ConfigSnapshot: Codable {
    var isHapticsEnabled: Bool
    var fireIntensity: Double
    var resetHour: Int
    var notificationsEnabled: Bool
    var themeStyle: String
    var privacyUrlString: String
}

final class FireConfigStore: ObservableObject {
    @Published var isHapticsEnabled: Bool = true
    @Published var fireIntensity: Double = 1.0
    @Published var resetHour: Int = 4
    @Published var notificationsEnabled: Bool = false
    @Published var themeStyle: String = "ember"
    @Published var privacyUrl: URL = URL(string: "https://spencerapps.github.io/steproad/privacy.html")!

    private let storageKey = "fire.config.snapshot"
    private var cancellables = Set<AnyCancellable>()

    init() {
        load()
        bindAutosave()
    }

    // MARK: - Derived values

    var clampedIntensity: Double {
        min(max(fireIntensity, 0.2), 1.5)
    }

    var normalizedResetHour: Int {
        max(0, min(23, resetHour))
    }

    // MARK: - Autosave

    private func bindAutosave() {
        Publishers.CombineLatest4($isHapticsEnabled, $fireIntensity, $resetHour, $notificationsEnabled)
            .combineLatest($themeStyle, $privacyUrl)
            .debounce(for: .seconds(0.4), scheduler: DispatchQueue.main)
            .sink { [weak self] primary, style, url in
                let (isHaptics, intensity, hour, notify) = primary
                self?.save(
                    isHapticsEnabled: isHaptics,
                    fireIntensity: intensity,
                    resetHour: hour,
                    notificationsEnabled: notify,
                    themeStyle: style,
                    privacyUrl: url
                )
            }
            .store(in: &cancellables)
    }

    private func save(
        isHapticsEnabled: Bool,
        fireIntensity: Double,
        resetHour: Int,
        notificationsEnabled: Bool,
        themeStyle: String,
        privacyUrl: URL
    ) {
        let snapshot = ConfigSnapshot(
            isHapticsEnabled: isHapticsEnabled,
            fireIntensity: fireIntensity,
            resetHour: resetHour,
            notificationsEnabled: notificationsEnabled,
            themeStyle: themeStyle,
            privacyUrlString: privacyUrl.absoluteString
        )

        do {
            let data = try JSONEncoder().encode(snapshot)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            // Intentionally ignore encoding errors
        }
    }

    // MARK: - Load

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }

        do {
            let snapshot = try JSONDecoder().decode(ConfigSnapshot.self, from: data)
            isHapticsEnabled = snapshot.isHapticsEnabled
            fireIntensity = snapshot.fireIntensity
            resetHour = snapshot.resetHour
            notificationsEnabled = snapshot.notificationsEnabled
            themeStyle = snapshot.themeStyle

            if let parsedUrl = URL(string: snapshot.privacyUrlString), parsedUrl.scheme != nil {
                privacyUrl = parsedUrl
            } else {
                privacyUrl = URL(string: "https://spencerapps.github.io/steproad/privacy.html")!
            }
        } catch {
            isHapticsEnabled = true
            fireIntensity = 1.0
            resetHour = 4
            notificationsEnabled = false
            themeStyle = "ember"
            privacyUrl = URL(string: "https://spencerapps.github.io/steproad/privacy.html")!
        }
    }
}
