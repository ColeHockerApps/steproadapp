import SwiftUI
import Combine

struct TodayStepItem: Identifiable, Equatable {
    let id: UUID
    let chunkId: UUID
    let indexInChunk: Int
    var isDone: Bool
    var isToday: Bool
}

final class TodayViewModel: ObservableObject {
    @Published var activeRoadId: UUID?
    @Published var stepItems: [TodayStepItem] = []
    @Published var todayStepsDone: Int = 0
    @Published var todayTotalSteps: Int = 0
    @Published var streakSnapshot: DailyStreak?

    private let streakForge: StreakForge
    private var cancellables = Set<AnyCancellable>()

    init(streakForge: StreakForge = StreakForge()) {
        self.streakForge = streakForge
    }

    // MARK: - Public API

    func refresh(from vault: TrailVault, config: FireConfigStore) {
        guard let road = vault.activeRoad() else {
            activeRoadId = nil
            stepItems = []
            todayStepsDone = 0
            todayTotalSteps = 0
            streakSnapshot = nil
            return
        }

        activeRoadId = road.id

        let resetHour = config.normalizedResetHour
        let now = Date()
        let today = shiftedDay(date: now, resetHour: resetHour)

        var items: [TodayStepItem] = []
        items.reserveCapacity(road.totalSteps)

        for chunk in road.chunks {
            for (index, point) in chunk.steps.enumerated() {
                let isToday: Bool
                if let doneAt = point.doneAt {
                    let doneDay = shiftedDay(date: doneAt, resetHour: resetHour)
                    isToday = (doneDay == today)
                } else {
                    isToday = false
                }

                let item = TodayStepItem(
                    id: point.id,
                    chunkId: chunk.id,
                    indexInChunk: index,
                    isDone: point.isDone,
                    isToday: isToday
                )
                items.append(item)
            }
        }

        let doneToday = items.filter { $0.isDone && $0.isToday }.count

        stepItems = items
        todayStepsDone = doneToday
        todayTotalSteps = items.count

        let currentStreak = vault.streak(for: road.id)
        let updatedStreak = streakForge.evaluateStreak(
            current: currentStreak,
            stepsDoneToday: doneToday,
            resetHour: resetHour
        )
        streakSnapshot = updatedStreak
        vault.updateStreak(for: road.id, streak: updatedStreak)
    }

    func toggleStep(stepId: UUID, in vault: TrailVault, config: FireConfigStore) {
        guard var road = vault.activeRoad() else { return }

        var changed = false
        for chunkIndex in road.chunks.indices {
            for stepIndex in road.chunks[chunkIndex].steps.indices {
                if road.chunks[chunkIndex].steps[stepIndex].id == stepId {
                    var step = road.chunks[chunkIndex].steps[stepIndex]
                    if step.isDone {
                        step.isDone = false
                        step.doneAt = nil
                    } else {
                        step.isDone = true
                        step.doneAt = Date()
                    }
                    road.chunks[chunkIndex].steps[stepIndex] = step
                    changed = true
                    break
                }
            }
            if changed { break }
        }

        if changed {
            vault.updateRoad(road)
            if config.isHapticsEnabled {
                EmberHaptics.shared.spark()
            }
            refresh(from: vault, config: config)
        }
    }

    // MARK: - Helpers

    private func shiftedDay(date: Date, resetHour: Int) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = .current

        let hour = calendar.component(.hour, from: date)
        if hour < resetHour {
            return calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: date)) ?? calendar.startOfDay(for: date)
        } else {
            return calendar.startOfDay(for: date)
        }
    }
}
