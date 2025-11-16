import SwiftUI
import Combine

struct TodayScreen: View {
    @EnvironmentObject private var tint: EmberTint
    @EnvironmentObject private var vault: TrailVault
    @EnvironmentObject private var config: FireConfigStore
    @EnvironmentObject private var vm: TodayViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                tint.background.ignoresSafeArea()
                content
            }
            .navigationTitle("Today")
        }
        .onAppear {
            vm.refresh(from: vault, config: config)
        }
        .onReceive(vault.$roads) { _ in
            vm.refresh(from: vault, config: config)
        }
        .onReceive(config.$resetHour) { _ in
            vm.refresh(from: vault, config: config)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if vm.activeRoadId == nil {
            emptyState
        } else {
            VStack(spacing: 16) {
                fireHeader
                stepSummary
                stepList
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
    }

    // MARK: - Header

    private var fireHeader: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(BlazeTokens.streakGlow)
                    .frame(width: 130, height: 130)
                    .shadow(radius: 18)

                Circle()
                    .strokeBorder(tint.surface, lineWidth: 4)
                    .frame(width: 140, height: 140)

                VStack(spacing: 4) {
                    Text("Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(streakNumberText)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(streakRecordText)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .padding(.top, 4)

            Text(roadTitleText)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
    }

    private var streakNumberText: String {
        guard let streak = vm.streakSnapshot else { return "0" }
        return "\(streak.current)"
    }

    private var streakRecordText: String {
        guard let streak = vm.streakSnapshot, streak.record > 0 else {
            return "No record yet"
        }
        return "Best: \(streak.record) days"
    }

    private var roadTitleText: String {
        guard let road = vault.activeRoad() else {
            return "No active Road"
        }
        return road.title
    }

    // MARK: - Summary

    private var stepSummary: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Steps today")
                    .font(.subheadline)
                Spacer()
                Text("\(vm.todayStepsDone)")
                    .font(.subheadline.weight(.semibold))
            }

            HStack {
                Text("Total steps on Road")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(vm.todayTotalSteps)")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
            }

            progressBar
        }
    }

    private var progressBar: some View {
        let fraction = vm.todayTotalSteps > 0
            ? Double(vm.todayStepsDone) / Double(vm.todayTotalSteps)
            : 0

        return VStack(spacing: 4) {
            ProgressView(value: fraction)
                .tint(BlazeTokens.fireMedium)

            HStack {
                Text(FormatKit.progressFraction(done: vm.todayStepsDone,
                                                total: vm.todayTotalSteps))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text(FormatKit.percent(fraction))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Step list

    private var stepList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today’s steps")
                .font(.subheadline.weight(.semibold))

            if vm.stepItems.isEmpty {
                Text("No steps available for this Road yet.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(vm.stepItems) { item in
                            stepRow(for: item)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private func stepRow(for item: TodayStepItem) -> some View {
        let iconName: String
        let tintColor: Color
        let background: Color

        if item.isDone {
            iconName = TrailGlyphs.stepFilled
            tintColor = BlazeTokens.stepDone
            background = BlazeTokens.stepDone.opacity(0.12)
        } else if item.isToday {
            iconName = TrailGlyphs.step
            tintColor = BlazeTokens.stepReady
            background = BlazeTokens.stepReady.opacity(0.10)
        } else {
            iconName = TrailGlyphs.step
            tintColor = BlazeTokens.stepLocked
            background = BlazeTokens.stepLocked.opacity(0.08)
        }

        return HStack(spacing: 12) {
            Image(systemName: iconName)
                .foregroundColor(tintColor)
                .font(.system(size: 20, weight: .semibold))

            VStack(alignment: .leading, spacing: 2) {
                Text(stepTitle(for: item))
                    .font(.subheadline)

                if item.isDone, let streak = vm.streakSnapshot, streak.current > 0 {
                    Text("Keeps the fire alive")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } else if item.isToday {
                    Text("Counts for today’s streak")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if item.isDone {
                Image(systemName: TrailGlyphs.check)
                    .foregroundColor(BlazeTokens.stepDone)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(background)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            vm.toggleStep(stepId: item.id, in: vault, config: config)
        }
    }

    private func stepTitle(for item: TodayStepItem) -> String {
        "Step \(item.indexInChunk + 1)"
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: TrailGlyphs.today)
                .font(.system(size: 48))
                .foregroundColor(tint.primary.opacity(0.6))

            Text("No Active Road")
                .font(.headline)

            Text("Create and activate a Road to start tracking your daily steps and streaks.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.top, 60)
    }
}
