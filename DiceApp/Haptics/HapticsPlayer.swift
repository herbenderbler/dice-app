import CoreHaptics
import UIKit

/// Candy Pop's roll haptic: a gumball rattling twice as the tumble starts,
/// then a medium landing thump timed to the cube's overshoot arrival.
/// Falls back to a single impact where CoreHaptics is unavailable
/// (including the Simulator, where `supportsHaptics` is false).
@MainActor
final class HapticsPlayer {
    private var engine: CHHapticEngine?
    private let supportsCoreHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
    private lazy var fallback = UIImpactFeedbackGenerator(style: .medium)

    func playRoll(reduceMotion: Bool) {
        guard supportsCoreHaptics else {
            fallback.impactOccurred()
            return
        }
        do {
            if engine == nil {
                let created = try CHHapticEngine()
                created.resetHandler = { [weak self] in
                    Task { @MainActor in self?.engine = nil }
                }
                engine = created
            }
            guard let engine else { return }
            try engine.start()

            let events: [CHHapticEvent]
            if reduceMotion {
                // No tumble to accompany — just the landing.
                events = [transient(at: 0, intensity: 1.0, sharpness: 0.4)]
            } else {
                events = [
                    transient(at: 0.00, intensity: 0.45, sharpness: 0.72),
                    transient(at: 0.12, intensity: 0.55, sharpness: 0.72),
                    transient(at: CandyPopTheme.tumbleDuration, intensity: 1.0, sharpness: 0.4),
                ]
            }
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            fallback.impactOccurred()
        }
    }

    private func transient(at time: TimeInterval, intensity: Float, sharpness: Float) -> CHHapticEvent {
        CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness),
            ],
            relativeTime: time
        )
    }
}
