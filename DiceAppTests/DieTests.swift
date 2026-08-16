import XCTest
@testable import DiceApp

final class DieTests: XCTestCase {
    func testRollWithSystemGeneratorStaysInRange() {
        let die = Die()
        for _ in 0..<10_000 {
            let value = die.roll()
            XCTAssertTrue((1...6).contains(value), "Rolled \(value), outside 1...6")
        }
    }

    func testSeededRollsAreDeterministic() {
        let die = Die()
        var first = SeededGenerator(seed: 0xD1CE)
        var second = SeededGenerator(seed: 0xD1CE)
        let firstSequence = (0..<100).map { _ in die.roll(using: &first) }
        let secondSequence = (0..<100).map { _ in die.roll(using: &second) }
        XCTAssertEqual(firstSequence, secondSequence)
    }

    func testDifferentSeedsDiverge() {
        let die = Die()
        var first = SeededGenerator(seed: 1)
        var second = SeededGenerator(seed: 2)
        let a = (0..<100).map { _ in die.roll(using: &first) }
        let b = (0..<100).map { _ in die.roll(using: &second) }
        XCTAssertNotEqual(a, b)
    }

    /// Sanity check against gross bias (wrong range, broken mapping, seeded
    /// generator sneaking into production). Chi-squared with df = 5; the
    /// threshold of 40 corresponds to p ≈ 1e-7, so a healthy generator
    /// essentially never trips it and the test stays CI-stable.
    func testSystemGeneratorIsRoughlyUniform() {
        let die = Die()
        let rolls = 60_000
        var counts = [Int](repeating: 0, count: 6)
        for _ in 0..<rolls {
            counts[die.roll() - 1] += 1
        }
        let expected = Double(rolls) / 6
        let chiSquared = counts.reduce(0.0) { partial, observed in
            let delta = Double(observed) - expected
            return partial + delta * delta / expected
        }
        XCTAssertLessThan(chiSquared, 40, "Suspiciously non-uniform counts: \(counts)")
    }

    func testCustomSideCountsRespectRange() {
        var generator = SeededGenerator(seed: 7)
        let d20 = Die(sides: 20)
        for _ in 0..<1_000 {
            let value = d20.roll(using: &generator)
            XCTAssertTrue((1...20).contains(value), "Rolled \(value), outside 1...20")
        }
    }
}
