import SwiftUI
import Combine

struct FireAuraView: View {
    @EnvironmentObject private var tint: EmberTint
    @EnvironmentObject private var config: FireConfigStore

    /// 0...1, used to scale aura strength
    let progress: Double

    var body: some View {
        ZStack {
            baseGlow
            innerGlow
            sparkCore
        }
        .compositingGroup()
        .shadow(color: auraColor.opacity(0.55 * intensity), radius: 18 * intensity, x: 0, y: 4)
    }

    // MARK: - Layers

    private var baseGlow: some View {
        Circle()
            .fill(auraGradient)
            .frame(width: 140 * intensity, height: 140 * intensity)
            .opacity(0.35 + 0.35 * normalizedProgress)
    }

    private var innerGlow: some View {
        Circle()
            .strokeBorder(auraColor.opacity(0.6), lineWidth: 6)
            .frame(width: 105 * intensity, height: 105 * intensity)
            .blur(radius: 2)
            .opacity(0.6 + 0.3 * normalizedProgress)
    }

    private var sparkCore: some View {
        Circle()
            .fill(auraColor)
            .frame(width: 48 * intensity, height: 48 * intensity)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.45), lineWidth: 2)
            )
            .overlay(
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .blur(radius: 18)
            )
            .scaleEffect(1.0 + 0.10 * normalizedProgress)
    }

    // MARK: - Derived values

    private var normalizedProgress: Double {
        max(0, min(progress, 1))
    }

    private var intensity: CGFloat {
        CGFloat(config.clampedIntensity)
    }

    private var auraColor: Color {
        switch normalizedProgress {
        case 0.0..<0.25:
            return BlazeTokens.fireLow
        case 0.25..<0.6:
            return BlazeTokens.fireMedium
        case 0.6..<0.9:
            return BlazeTokens.fireHigh
        default:
            return BlazeTokens.fireUltra
        }
    }

    private var auraGradient: LinearGradient {
        LinearGradient(
            colors: [
                auraColor.opacity(0.1),
                auraColor.opacity(0.55),
                tint.primary.opacity(0.4)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
