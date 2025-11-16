import SwiftUI
import Combine

final class RoadsViewModel: ObservableObject {
    @Published var newRoadTitle: String = ""
    @Published var newRoadTargetSteps: Int = 250
    @Published var editingRoad: Road?
    @Published var isPresentingEditor: Bool = false

    private let lattice: StepLattice

    init(lattice: StepLattice = .shared) {
        self.lattice = lattice
    }

    // MARK: - Accessors

    func roads(in vault: TrailVault) -> [Road] {
        vault.roads.sorted { lhs, rhs in
            if lhs.isActive != rhs.isActive {
                return lhs.isActive && !rhs.isActive
            }
            return lhs.createdAt < rhs.createdAt
        }
    }

    func activeRoad(in vault: TrailVault) -> Road? {
        vault.activeRoad()
    }

    // MARK: - Creation

    func prepareNewRoad() {
        newRoadTitle = ""
        newRoadTargetSteps = 250
        editingRoad = nil
        isPresentingEditor = true
    }

    func createRoad(in vault: TrailVault) {
        let trimmedTitle = newRoadTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard newRoadTargetSteps > 0 else { return }

        let title = trimmedTitle.isEmpty ? defaultTitle(for: vault) : trimmedTitle
        let chunks = lattice.makeChunks(for: newRoadTargetSteps)
        let road = vault.addRoad(title: title, chunks: chunks)

        if vault.activeRoad() == nil {
            vault.setActiveRoad(road)
        }

        isPresentingEditor = false
    }

    // MARK: - Editing

    func beginEditing(_ road: Road) {
        editingRoad = road
        newRoadTitle = road.title
        newRoadTargetSteps = road.totalSteps
        isPresentingEditor = true
    }

    func applyEdit(in vault: TrailVault) {
        guard var road = editingRoad else { return }

        let trimmedTitle = newRoadTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTitle.isEmpty {
            road.title = trimmedTitle
        }

        if newRoadTargetSteps > 0, newRoadTargetSteps != road.totalSteps {
            let rebuilt = lattice.rebuildChunks(for: newRoadTargetSteps, preserving: road)
            road.chunks = rebuilt
        }

        vault.updateRoad(road)
        editingRoad = nil
        isPresentingEditor = false
    }

    func cancelEdit() {
        editingRoad = nil
        isPresentingEditor = false
    }

    // MARK: - Actions

    func setActive(_ road: Road, in vault: TrailVault) {
        vault.setActiveRoad(road)
    }

    func delete(_ road: Road, in vault: TrailVault) {
        vault.removeRoad(road)
    }

    // MARK: - Display helpers

    func progressText(for road: Road) -> String {
        FormatKit.progressFraction(done: road.completedSteps, total: road.totalSteps)
    }

    func percentText(for road: Road) -> String {
        FormatKit.percent(road.progress)
    }

    func fireLevel(for road: Road, in vault: TrailVault) -> DailyStreak? {
        vault.streak(for: road.id)
    }

    // MARK: - Private

    private func defaultTitle(for vault: TrailVault) -> String {
        let base = "New Road"
        let existing = vault.roads.map { $0.title }

        if existing.contains(base) == false {
            return base
        }

        var index = 2
        while index < 999 {
            let candidate = "\(base) \(index)"
            if existing.contains(candidate) == false {
                return candidate
            }
            index += 1
        }

        return UUID().uuidString
    }
}
