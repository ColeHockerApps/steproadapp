import SwiftUI
import Combine

struct FormatKit {

    static func percent(_ value: Double) -> String {
        let clamped = max(0, min(value, 1))
        let percent = Int(clamped * 100)
        return "\(percent)%"
    }

    static func progressFraction(done: Int, total: Int) -> String {
        guard total > 0 else { return "0/0" }
        return "\(done)/\(total)"
    }

    static func streakDay(_ count: Int) -> String {
        if count <= 0 {
            return "Day 0"
        }
        return "Day \(count)"
    }

    static func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    static func longDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }

    static func chunkLabel(size: Int) -> String {
        "\(size) steps"
    }

    static func fireIntensityText(_ value: Double) -> String {
        let clamped = max(0, min(value, 2))
        return String(format: "%.2f×", clamped)
    }
}
