import SwiftUI
import Combine

final class StreakForge {

    // MARK: - Public API

    func evaluateStreak(
        current: DailyStreak?,
        stepsDoneToday: Int,
        resetHour: Int,
        dateProvider: () -> Date = { Date() }
    ) -> DailyStreak {

        let now = dateProvider()
        let today = shiftedDay(date: now, resetHour: resetHour)

        // No previous streak
        guard let streak = current else {
            if stepsDoneToday > 0 {
                return DailyStreak(
                    current: 1,
                    record: 1,
                    lastDate: today
                )
            } else {
                return DailyStreak(
                    current: 0,
                    record: 0,
                    lastDate: today
                )
            }
        }

        let last = streak.lastDate
        let daysPassed = daysBetween(last, today)

        switch daysPassed {

        case 0:
            // Same streak day
            if stepsDoneToday > 0 {
                let updated = streak.current
                let newRecord = max(streak.record, updated)
                return DailyStreak(
                    current: updated,
                    record: newRecord,
                    lastDate: streak.lastDate
                )
            } else {
                return streak
            }

        case 1:
            // Next calendar day
            if stepsDoneToday > 0 {
                let updated = streak.current + 1
                let newRecord = max(streak.record, updated)
                return DailyStreak(
                    current: updated,
                    record: newRecord,
                    lastDate: today
                )
            } else {
                // Streak breaks
                return DailyStreak(
                    current: 0,
                    record: streak.record,
                    lastDate: today
                )
            }

        default:
            // Too many days passed — streak is gone
            if stepsDoneToday > 0 {
                return DailyStreak(
                    current: 1,
                    record: max(streak.record, 1),
                    lastDate: today
                )
            } else {
                return DailyStreak(
                    current: 0,
                    record: streak.record,
                    lastDate: today
                )
            }
        }
    }

    // MARK: - Optional weekly restore
    func restoreOncePerWeek(
        streak: DailyStreak,
        dateProvider: () -> Date = { Date() }
    ) -> DailyStreak {
        let now = dateProvider()
        let last = streak.lastDate

        let diff = daysBetween(last, now)
        if diff <= 7 {
            return DailyStreak(
                current: max(1, streak.current),
                record: max(streak.record, 1),
                lastDate: now
            )
        } else {
            return streak
        }
    }

    // MARK: - Helpers

    private func shiftedDay(date: Date, resetHour: Int) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = .current

        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)

        if let hour = components.hour, hour < resetHour {
            return calendar.date(byAdding: .day, value: -1, to: date) ?? date
        }

        return date
    }

    private func daysBetween(_ a: Date, _ b: Date) -> Int {
        let calendar = Calendar.current
        let aDay = calendar.startOfDay(for: a)
        let bDay = calendar.startOfDay(for: b)
        let diff = calendar.dateComponents([.day], from: aDay, to: bDay)
        return diff.day ?? 0
    }
}
