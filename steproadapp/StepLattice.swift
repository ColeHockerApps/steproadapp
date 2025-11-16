import SwiftUI
import Combine

final class StepLattice {

    static let shared = StepLattice()

    private init() {}

    // MARK: - Public API

    func makeChunks(for targetSteps: Int) -> [StepChunk] {
        guard targetSteps > 0 else { return [] }

        let pattern = [25, 50, 100, 200, 1000]
        var remaining = targetSteps
        var chunks: [StepChunk] = []

        var patternIndex = 0

        while remaining > 0 {
            let size = pattern[patternIndex]
            let stepsInChunk = min(size, remaining)

            let points = makeStepPoints(count: stepsInChunk)
            let chunk = StepChunk(
                id: UUID(),
                size: size,
                steps: points
            )
            chunks.append(chunk)

            remaining -= stepsInChunk
            patternIndex = (patternIndex + 1) % pattern.count
        }

        return chunks
    }

    func rebuildChunks(
        for targetSteps: Int,
        preserving progressRoad: Road?
    ) -> [StepChunk] {
        guard let road = progressRoad, targetSteps > 0 else {
            return makeChunks(for: targetSteps)
        }

        let flatExisting = flattenSteps(from: road.chunks)
        let totalExisting = flatExisting.count

        let newChunks = makeChunks(for: targetSteps)
        let flatNew = flattenSteps(from: newChunks)

        let toCopy = min(totalExisting, flatNew.count)
        if toCopy == 0 {
            return newChunks
        }

        var updatedFlatNew = flatNew
        for index in 0..<toCopy {
            let source = flatExisting[index]
            var target = updatedFlatNew[index]
            target.isDone = source.isDone
            target.doneAt = source.doneAt
            updatedFlatNew[index] = target
        }

        var rebuiltChunks: [StepChunk] = []
        var cursor = 0

        for chunk in newChunks {
            let count = chunk.steps.count
            let upper = min(cursor + count, updatedFlatNew.count)
            if cursor >= upper { break }

            let slice = Array(updatedFlatNew[cursor..<upper])
            let rebuilt = StepChunk(
                id: chunk.id,
                size: chunk.size,
                steps: slice
            )
            rebuiltChunks.append(rebuilt)
            cursor = upper
        }

        return rebuiltChunks
    }

    // MARK: - Helpers

    private func makeStepPoints(count: Int) -> [StepPoint] {
        guard count > 0 else { return [] }
        var points: [StepPoint] = []
        points.reserveCapacity(count)

        for _ in 0..<count {
            points.append(
                StepPoint(
                    id: UUID(),
                    isDone: false,
                    doneAt: nil
                )
            )
        }

        return points
    }

    private func flattenSteps(from chunks: [StepChunk]) -> [StepPoint] {
        chunks.flatMap { $0.steps }
    }
}
