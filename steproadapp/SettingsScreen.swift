import SwiftUI
import Combine

struct SettingsScreen: View {
    @EnvironmentObject private var tint: EmberTint
    @EnvironmentObject private var config: FireConfigStore
    @EnvironmentObject private var vm: SettingsViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                tint.background.ignoresSafeArea()
                content
            }
            .navigationTitle("Settings")
        }
        .onAppear {
            vm.sync(from: config)
        }
        .onReceive(config.$fireIntensity) { _ in
            vm.sync(from: config)
        }
        .onReceive(config.$themeStyle) { _ in
            vm.sync(from: config)
        }
        .sheet(isPresented: $vm.isShowingPrivacy) {
            PrivacySparkPage(url: vm.privacyUrl(from: config))
        }
    }

    // MARK: - Content

    private var content: some View {
        Form {
            //appearanceSection
           // fireSection
            rhythmSection
           // notificationsSection
            privacySection
        }
        .scrollContentBackground(.hidden)
        .background(tint.background)
    }

    // MARK: - Sections

    private var appearanceSection: some View {
        Section {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(tint.primary.opacity(0.15))
                        .frame(width: 42, height: 42)

                    Image(systemName: TrailGlyphs.fireMedium)
                        .foregroundColor(tint.primary)
                        .font(.system(size: 20, weight: .semibold))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Theme")
                        .font(.subheadline.weight(.semibold))
                    Text(vm.selectedThemeStyle.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Picker("", selection: Binding(
                    get: { vm.selectedThemeStyle },
                    set: { vm.updateThemeStyle($0, in: config) }
                )) {
                    Text("Ember").tag("ember")
                    Text("Night").tag("night")
                    Text("Soft").tag("soft")
                }
                .pickerStyle(.menu)
                .labelsHidden()
            }
        } header: {
            Text("Appearance")
        }
    }

    private var fireSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: TrailGlyphs.fireHigh)
                        .foregroundColor(BlazeTokens.fireMedium)
                    Text("Fire intensity")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(vm.intensityPreviewText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Slider(
                    value: Binding(
                        get: { config.fireIntensity },
                        set: { vm.updateIntensity($0, in: config) }
                    ),
                    in: 0.3...1.5
                )

                Text("Controls how bright and vivid fire elements look across the app.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Toggle(isOn: Binding(
                get: { config.isHapticsEnabled },
                set: { vm.setHapticsEnabled($0, in: config) }
            )) {
                HStack {
                    Image(systemName: TrailGlyphs.stepFilled)
                        .foregroundColor(tint.primary)
                    Text("Haptics")
                }
            }
        } header: {
            Text("Fire & Feedback")
        }
    }

    private var rhythmSection: some View {
        Section {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Day reset hour")
                        .font(.subheadline.weight(.semibold))
                    Text("When a new streak day starts")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Picker("", selection: Binding(
                    get: { config.normalizedResetHour },
                    set: { vm.setResetHour($0, in: config) }
                )) {
                    Text("0").tag(0)
                    Text("3").tag(3)
                    Text("4").tag(4)
                    Text("6").tag(6)
                    Text("8").tag(8)
                }
                .pickerStyle(.menu)
                .labelsHidden()
            }
        } header: {
            Text("Daily Rhythm")
        }
    }

    private var notificationsSection: some View {
        Section {
            Toggle(isOn: Binding(
                get: { config.notificationsEnabled },
                set: { vm.setNotificationsEnabled($0, in: config) }
            )) {
                HStack {
                    Image(systemName: "bell.badge")
                        .foregroundColor(.red)
                    Text("Gentle reminders")
                }
            }

            Text("Use subtle reminders to keep your Road moving without pressure.")
                .font(.caption2)
                .foregroundColor(.secondary)
        } header: {
            Text("Reminders")
        }
    }

    private var privacySection: some View {
        Section {
            Button {
                vm.showPrivacy()
            } label: {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.blue.opacity(0.12))
                            .frame(width: 34, height: 34)

                        Image(systemName: "doc.text.magnifyingglass")
                            .foregroundColor(.blue)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Privacy")
                            .font(.subheadline.weight(.semibold))
//                        Text(config.privacyUrl.absoluteString)
//                            .font(.caption2)
//                            .foregroundColor(.secondary)
//                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        } header: {
            Text("Privacy & About")
        }
    }
}
