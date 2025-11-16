import SwiftUI
import Combine

struct JourneyChunkItem: Identifiable, Equatable {
    let id: UUID
    let size: Int
    let totalSteps: Int
    let completedSteps: Int

    var progress: Double {
        guard totalSteps > 0 else { return 0 }
        return Double(completedSteps) / Double(totalSteps)
    }

    var label: String {
        FormatKit.chunkLabel(size: size)
    }
}

final class JourneyViewModel: ObservableObject {
    @Published var selectedRoadId: UUID?
    @Published var chunkItems: [JourneyChunkItem] = []
    @Published var totalSteps: Int = 0
    @Published var completedSteps: Int = 0
    @Published var overallProgress: Double = 0
    @Published var createdAtText: String = ""
    @Published var hasRoads: Bool = false

    // MARK: - Public API

    func refresh(from vault: TrailVault) {
        let roads = vault.roads
        hasRoads = !roads.isEmpty

        guard !roads.isEmpty else {
            selectedRoadId = nil
            chunkItems = []
            totalSteps = 0
            completedSteps = 0
            overallProgress = 0
            createdAtText = ""
            return
        }

        let road: Road
        if let id = selectedRoadId, let existing = roads.first(where: { $0.id == id }) {
            road = existing
        } else if let active = vault.activeRoad() {
            road = active
            selectedRoadId = active.id
        } else {
            road = roads[0]
            selectedRoadId = road.id
        }

        buildState(for: road)
    }

    func selectRoad(_ road: Road, vault: TrailVault) {
        selectedRoadId = road.id
        buildState(for: road)
    }

    // MARK: - Display helpers

    func progressText() -> String {
        FormatKit.progressFraction(done: completedSteps, total: totalSteps)
    }

    func percentText() -> String {
        FormatKit.percent(overallProgress)
    }

    // MARK: - Private

    private func buildState(for road: Road) {
        totalSteps = road.totalSteps
        completedSteps = road.completedSteps
        overallProgress = road.progress
        createdAtText = FormatKit.longDate(road.createdAt)

        var items: [JourneyChunkItem] = []
        items.reserveCapacity(road.chunks.count)

        for chunk in road.chunks {
            let item = JourneyChunkItem(
                id: chunk.id,
                size: chunk.size,
                totalSteps: chunk.totalSteps,
                completedSteps: chunk.completedSteps
            )
            items.append(item)
        }

        chunkItems = items
    }
}
