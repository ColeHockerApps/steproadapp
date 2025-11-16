import SwiftUI
import Combine

// Core Road model
struct Road: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var chunks: [StepChunk]
    var createdAt: Date
    var isActive: Bool

    var totalSteps: Int {
        chunks.reduce(0) { $0 + $1.totalSteps }
    }

    var completedSteps: Int {
        chunks.reduce(0) { $0 + $1.completedSteps }
    }

    var progress: Double {
        guard totalSteps > 0 else { return 0 }
        return Double(completedSteps) / Double(totalSteps)
    }
}

// StepChunk represents 25/50/100/200/1000 blocks
struct StepChunk: Identifiable, Codable, Equatable {
    let id: UUID
    let size: Int
    var steps: [StepPoint]

    var totalSteps: Int { steps.count }
    var completedSteps: Int { steps.filter { $0.isDone }.count }
}

// Individual mini-step
struct StepPoint: Identifiable, Codable, Equatable {
    let id: UUID
    var isDone: Bool
    var doneAt: Date?
}

// Daily streak state
struct DailyStreak: Codable, Equatable {
    var current: Int
    var record: Int
    var lastDate: Date
}

// Profile-level fire status
struct ProfileSpark: Codable, Equatable {
    var level: Int
    var earnedFireModes: [String]
}
