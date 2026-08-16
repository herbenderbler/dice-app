import XCTest
@testable import DiceApp

@MainActor
final class DiceRollViewModelTests: XCTestCase {
    func testRollLandsOnSeededValue() async {
        // With zero flicker ticks the final face is the first draw, so it
        // must match a reference die reading the same seeded sequence.
        var reference = SeededGenerator(seed: 42)
        let expected = Die().roll(using: &reference)

        let viewModel = DiceRollViewModel(
            generator: SeededGenerator(seed: 42),
            flickerCount: 0,
            flickerInterval: .zero
        )
        await viewModel.roll()

        XCTAssertEqual(viewModel.displayedFace, expected)
        XCTAssertEqual(viewModel.rollCount, 1)
        XCTAssertFalse(viewModel.isRolling)
    }

    func testRollAlwaysEndsInRange() async {
        let viewModel = DiceRollViewModel(flickerCount: 2, flickerInterval: .zero)
        for _ in 0..<50 {
            await viewModel.roll()
            XCTAssertTrue((1...6).contains(viewModel.displayedFace))
        }
        XCTAssertEqual(viewModel.rollCount, 50)
    }

    func testTapsWhileRollingAreIgnored() async {
        let viewModel = DiceRollViewModel(flickerCount: 3, flickerInterval: .milliseconds(60))

        // Poll until the first roll has definitely engaged the guard, so
        // the second roll's rejection is deterministic, not timing-based.
        async let firstRoll: Void = viewModel.roll()
        var yields = 0
        while !viewModel.isRolling && yields < 100_000 {
            await Task.yield()
            yields += 1
        }
        XCTAssertTrue(viewModel.isRolling, "First roll never started")

        await viewModel.roll()
        await firstRoll

        XCTAssertEqual(viewModel.rollCount, 1)
    }
}
