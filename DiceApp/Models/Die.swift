import Foundation

/// A fair n-sided die. Rolls are uniform over `1...sides`.
///
/// The generator is injectable so tests can drive a deterministic sequence;
/// production uses `SystemRandomNumberGenerator`, the OS CSPRNG.
/// `Int.random(in:using:)` performs unbiased range reduction — never replace
/// it with a `%`-based mapping, which would skew the face distribution.
struct Die: Equatable {
    let sides: Int

    init(sides: Int = 6) {
        precondition(sides >= 2, "A die needs at least two sides")
        self.sides = sides
    }

    func roll(using generator: inout some RandomNumberGenerator) -> Int {
        Int.random(in: 1...sides, using: &generator)
    }

    func roll() -> Int {
        var generator = SystemRandomNumberGenerator()
        return roll(using: &generator)
    }
}
