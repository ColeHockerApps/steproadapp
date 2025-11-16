import SwiftUI
import Combine

struct BlazeTokens {
    // Fire intensity levels
    static var fireLow: Color {
        Color(red: 1.00, green: 0.70, blue: 0.30)
    }

    static var fireMedium: Color {
        Color(red: 1.00, green: 0.50, blue: 0.20)
    }

    static var fireHigh: Color {
        Color(red: 1.00, green: 0.32, blue: 0.12)
    }

    static var fireUltra: Color {
        Color(red: 1.00, green: 0.18, blue: 0.08)
    }

    // Progress gradients
    static var roadGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.98, green: 0.52, blue: 0.25),
                Color(red: 1.00, green: 0.75, blue: 0.30)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var streakGlow: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.00, green: 0.75, blue: 0.40),
                Color(red: 1.00, green: 0.45, blue: 0.20)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // Status indicators
    static var stepReady: Color {
        Color(red: 0.95, green: 0.45, blue: 0.20)
    }

    static var stepDone: Color {
        Color(red: 0.30, green: 0.75, blue: 0.35)
    }

    static var stepLocked: Color {
        Color(red: 0.75, green: 0.75, blue: 0.75)
    }
}
