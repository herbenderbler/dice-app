import Foundation
import Observation

/// Owns the state of a roll. The result is drawn from the generator the
/// moment the roll starts; the 3D tumble that follows is pure
/// presentation, choreographed to land on that face — the animation never
/// influences the outcome.
@MainActor
@Observable
final class DiceRollViewModel {
    private(set) var displayedFace = 1
    private(set) var isRolling = false
    private(set) var rollCount = 0
    private(set) var settledCount = 0

    private let die: Die
    private var generator: AnyRandomNumberGenerator
    private let rollDuration: Duration

    init(
        die: Die = Die(),
        generator: any RandomNumberGenerator = SystemRandomNumberGenerator(),
        rollDuration: Duration = CandyPopTheme.rollDuration
    ) {
        self.die = die
        self.generator = AnyRandomNumberGenerator(generator)
        self.rollDuration = rollDuration
    }

    /// Rolls the die. Taps arriving mid-tumble are ignored rather than
    /// queued or restarted. Repeats are allowed: a real die lands on the
    /// same face 1-in-6 of the time, and forcing a change would bias the
    /// distribution — the tumble makes a repeated face read as a fresh
    /// roll.
    func roll() async {
        guard !isRolling else { return }
        isRolling = true
        displayedFace = die.roll(using: &generator)
        rollCount += 1
        try? await Task.sleep(for: rollDuration)
        isRolling = false
        settledCount += 1
    }
}
