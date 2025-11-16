import SwiftUI
import Combine

struct EmberComponents {

    // MARK: - Card

    struct Card<Content: View>: View {
        @EnvironmentObject private var tint: EmberTint

        let title: String?
        let subtitle: String?
        let content: Content

        init(
            title: String? = nil,
            subtitle: String? = nil,
            @ViewBuilder content: () -> Content
        ) {
            self.title = title
            self.subtitle = subtitle
            self.content = content()
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                if title != nil || subtitle != nil {
                    VStack(alignment: .leading, spacing: 2) {
                        if let title {
                            Text(title)
                                .font(.subheadline.weight(.semibold))
                        }
                        if let subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                content
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(tint.surface)
                    .shadow(radius: 6, x: 0, y: 2)
            )
        }
    }

    // MARK: - Section header

    struct SectionHeader: View {
        let title: String
        let iconName: String?

        init(title: String, iconName: String? = nil) {
            self.title = title
            self.iconName = iconName
        }

        var body: some View {
            HStack(spacing: 6) {
                if let iconName {
                    Image(systemName: iconName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .textCase(nil)
                Spacer()
            }
        }
    }

    // MARK: - Pill

    struct PillLabel: View {
        let text: String
        let iconName: String?

        init(text: String, iconName: String? = nil) {
            self.text = text
            self.iconName = iconName
        }

        var body: some View {
            HStack(spacing: 6) {
                if let iconName {
                    Image(systemName: iconName)
                        .font(.caption2)
                }
                Text(text)
                    .font(.caption2.weight(.medium))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.secondary.opacity(0.12))
            )
        }
    }
}
