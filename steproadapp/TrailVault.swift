import SwiftUI
import Combine

private struct VaultSnapshot: Codable {
    var roads: [Road]
    var streaks: [String: DailyStreak]
    var profile: ProfileSpark
}

final class TrailVault: ObservableObject {
    @Published var roads: [Road] = []
    @Published var streaks: [UUID: DailyStreak] = [:]
    @Published var profile: ProfileSpark = ProfileSpark(level: 1, earnedFireModes: [])

    private let storageKey = "trail.vault.snapshot"
    private var cancellables = Set<AnyCancellable>()

    init() {
        load()
        bindAutosave()
    }

    // MARK: - Public API

    func addRoad(title: String, chunks: [StepChunk]) -> Road {
        let road = Road(
            id: UUID(),
            title: title,
            chunks: chunks,
            createdAt: Date(),
            isActive: roads.isEmpty
        )
        roads.append(road)
        return road
    }

    func updateRoad(_ road: Road) {
        guard let index = roads.firstIndex(where: { $0.id == road.id }) else { return }
        roads[index] = road
    }

    func removeRoad(_ road: Road) {
        roads.removeAll { $0.id == road.id }
        streaks[road.id] = nil

        if roads.contains(where: { $0.isActive }) == false {
            roads.first.map { setActiveRoad($0) }
        }
    }

    func activeRoad() -> Road? {
        roads.first(where: { $0.isActive })
    }

    func setActiveRoad(_ road: Road) {
        roads = roads.map { item in
            var updated = item
            updated.isActive = (item.id == road.id)
            return updated
        }
    }

    func streak(for roadId: UUID) -> DailyStreak? {
        streaks[roadId]
    }

    func updateStreak(for roadId: UUID, streak: DailyStreak) {
        streaks[roadId] = streak
    }

    // MARK: - Persistence

    private func bindAutosave() {
        Publishers.CombineLatest3($roads, $streaks, $profile)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] roads, streaks, profile in
                self?.save(roads: roads, streaks: streaks, profile: profile)
            }
            .store(in: &cancellables)
    }

    private func save(roads: [Road], streaks: [UUID: DailyStreak], profile: ProfileSpark) {
        let mappedStreaks = streaks.reduce(into: [String: DailyStreak]()) { result, pair in
            result[pair.key.uuidString] = pair.value
        }

        let snapshot = VaultSnapshot(
            roads: roads,
            streaks: mappedStreaks,
            profile: profile
        )

        do {
            let data = try JSONEncoder().encode(snapshot)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            // Intentionally silent: persistence errors should not break the app flow
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }

        do {
            let snapshot = try JSONDecoder().decode(VaultSnapshot.self, from: data)
            roads = snapshot.roads
            profile = snapshot.profile

            var restoredStreaks: [UUID: DailyStreak] = [:]
            for (key, value) in snapshot.streaks {
                if let uuid = UUID(uuidString: key) {
                    restoredStreaks[uuid] = value
                }
            }
            streaks = restoredStreaks

            if roads.contains(where: { $0.isActive }) == false, let first = roads.first {
                setActiveRoad(first)
            }
        } catch {
            roads = []
            streaks = [:]
            profile = ProfileSpark(level: 1, earnedFireModes: [])
        }
    }
}
