import SwiftUI
import Combine

struct RoadChipItem: Identifiable, Equatable {
    let id: UUID
    let index: Int
    var isDone: Bool
    var isCurrent: Bool
}

struct RoadChipsView: View {
    let items: [RoadChipItem]
    let onTap: (RoadChipItem) -> Void

    private let columns: [GridItem] = Array(
        repeating: GridItem(.flexible(minimum: 44, maximum: 72), spacing: 8),
        count: 5
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(items) { item in
                chip(for: item)
            }
        }
    }

    // MARK: - Chip

    private func chip(for item: RoadChipItem) -> some View {
        let style = chipStyle(for: item)

        return Button {
            onTap(item)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(style.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(style.border, lineWidth: style.borderWidth)
                    )

                VStack(spacing: 4) {
                    Image(systemName: style.icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(style.iconColor)

                    Text("\(item.index + 1)")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(style.textColor)
                }
                .padding(.vertical, 6)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Style

    private func chipStyle(for item: RoadChipItem) -> ChipStyle {
        if item.isDone {
            return ChipStyle(
                background: BlazeTokens.stepDone.opacity(0.18),
                border: BlazeTokens.stepDone.opacity(0.75),
                borderWidth: 1.4,
                icon: TrailGlyphs.check,
                iconColor: BlazeTokens.stepDone,
                textColor: BlazeTokens.stepDone
            )
        }

        if item.isCurrent {
            return ChipStyle(
                background: BlazeTokens.stepReady.opacity(0.12),
                border: BlazeTokens.stepReady.opacity(0.9),
                borderWidth: 1.4,
                icon: TrailGlyphs.step,
                iconColor: BlazeTokens.stepReady,
                textColor: BlazeTokens.stepReady
            )
        }

        return ChipStyle(
            background: BlazeTokens.stepLocked.opacity(0.08),
            border: BlazeTokens.stepLocked.opacity(0.4),
            borderWidth: 1.0,
            icon: TrailGlyphs.step,
            iconColor: BlazeTokens.stepLocked,
            textColor: BlazeTokens.stepLocked
        )
    }

    private struct ChipStyle {
        let background: Color
        let border: Color
        let borderWidth: CGFloat
        let icon: String
        let iconColor: Color
        let textColor: Color
    }
}
