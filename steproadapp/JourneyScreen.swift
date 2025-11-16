import SwiftUI
import Combine

struct JourneyScreen: View {
    @EnvironmentObject private var tint: EmberTint
    @EnvironmentObject private var vault: TrailVault
    @EnvironmentObject private var vm: JourneyViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                tint.background.ignoresSafeArea()
                content
            }
            .navigationTitle("Journey")
        }
        .onAppear {
            vm.refresh(from: vault)
        }
        .onReceive(vault.$roads) { _ in
            vm.refresh(from: vault)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if !vm.hasRoads {
            emptyState
        } else {
            VStack(spacing: 16) {
                roadSelector
                summaryCard
                chunkList
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
    }

    // MARK: - Road selector

    private var roadSelector: some View {
        let roads = vault.roads

        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(roads) { road in
                    let isSelected = road.id == (vm.selectedRoadId ?? vault.activeRoad()?.id)
                    Button {
                        vm.selectRoad(road, vault: vault)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: TrailGlyphs.roads)
                                .font(.caption)
                            Text(road.title)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule(style: .continuous)
                                .fill(isSelected ? tint.primary.opacity(0.18) : tint.surface)
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(isSelected ? tint.primary : tint.surface, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Summary

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedRoadTitle)
                        .font(.headline)
                        .lineLimit(2)

                    if !vm.createdAtText.isEmpty {
                        Text("Since \(vm.createdAtText)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(vm.percentText())
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(BlazeTokens.fireMedium)

                    Text(vm.progressText())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            ProgressView(value: vm.overallProgress)
                .tint(BlazeTokens.fireMedium)

            HStack {
                Text("Total steps")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(vm.totalSteps)")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(tint.surface)
                .shadow(radius: 6, x: 0, y: 2)
        )
    }

    private var selectedRoadTitle: String {
        guard let id = vm.selectedRoadId else {
            return vault.activeRoad()?.title ?? "Road"
        }
        return vault.roads.first(where: { $0.id == id })?.title
            ?? vault.activeRoad()?.title
            ?? "Road"
    }

    // MARK: - Chunks

    private var chunkList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Milestones")
                .font(.subheadline.weight(.semibold))

            if vm.chunkItems.isEmpty {
                Text("There are no milestones yet for this Road.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(vm.chunkItems) { chunk in
                            chunkRow(for: chunk)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
    }

    private func chunkRow(for chunk: JourneyChunkItem) -> some View {
        let fraction = chunk.progress
        let percentText = FormatKit.percent(fraction)

        let fireColor: Color
        switch fraction {
        case 0.0..<0.25:
            fireColor = BlazeTokens.fireLow
        case 0.25..<0.75:
            fireColor = BlazeTokens.fireMedium
        case 0.75..<0.99:
            fireColor = BlazeTokens.fireHigh
        default:
            fireColor = BlazeTokens.fireUltra
        }

        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(fireColor.opacity(0.18))
                    .frame(width: 38, height: 38)

                Image(systemName: TrailGlyphs.chunk50)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(fireColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(chunk.label)
                    .font(.subheadline.weight(.medium))

                ProgressView(value: fraction)
                    .tint(fireColor)

                HStack {
                    Text("\(chunk.completedSteps)/\(chunk.totalSteps) steps")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(percentText)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(tint.surface)
        )
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: TrailGlyphs.journey)
                .font(.system(size: 48))
                .foregroundColor(tint.primary.opacity(0.6))

            Text("No Roads Yet")
                .font(.headline)

            Text("Create a Road first and you will see your long-term journey here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.top, 60)
    }
}
