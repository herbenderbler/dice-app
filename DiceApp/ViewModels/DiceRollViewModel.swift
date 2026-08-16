import Foundation
import Observation

/// Owns the state and choreography of a roll: a short cosmetic flicker
/// through faces, then the real entropy-backed result.
@MainActor
@Observable
final class DiceRollViewModel {
    private(set) var displayedFace = 1
    private(set) var isRolling = false
    private(set) var rollCount = 0

    private let die: Die
    private var generator: AnyRandomNumberGenerator
    private let flickerCount: Int
    private let flickerInterval: Duration

    init(
        die: Die = Die(),
        generator: any RandomNumberGenerator = SystemRandomNumberGenerator(),
        flickerCount: Int = 8,
        flickerInterval: Duration = .milliseconds(70)
    ) {
        self.die = die
        self.generator = AnyRandomNumberGenerator(generator)
        self.flickerCount = flickerCount
        self.flickerInterval = flickerInterval
    }

    /// Rolls the die. Taps arriving mid-roll are ignored rather than queued
    /// or restarted. The flicker faces are cosmetic — forced to differ from
    /// the face on screen so the tumble reads clearly. Only the final value
    /// is the roll's result, drawn fresh with repeats allowed: a real die
    /// lands on the same face 1-in-6 of the time, and forcing a change
    /// would bias the distribution.
    func roll() async {
        guard !isRolling else { return }
        isRolling = true
        defer { isRolling = false }

        for _ in 0..<flickerCount {
            displayedFace = cosmeticFace(differentFrom: displayedFace)
            try? await Task.sleep(for: flickerInterval)
        }

        displayedFace = die.roll(using: &generator)
        rollCount += 1
    }

    private func cosmeticFace(differentFrom current: Int) -> Int {
        var face = die.roll(using: &generator)
        while face == current {
            face = die.roll(using: &generator)
        }
        return face
    }
}
