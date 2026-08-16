import Foundation

/// Type-erasing wrapper so a `RandomNumberGenerator` can be held as stored
/// state (the view model keeps one across rolls) while remaining swappable
/// with a seeded generator in tests.
struct AnyRandomNumberGenerator: RandomNumberGenerator {
    private var base: any RandomNumberGenerator

    init(_ base: any RandomNumberGenerator) {
        self.base = base
    }

    mutating func next() -> UInt64 {
        base.next()
    }
}
