import Accessibility
import SwiftUI

/// The app's single screen: a centered die, with the entire screen acting
/// as the roll button.
struct DiceRollScreen: View {
    @State private var viewModel = DiceRollViewModel()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Consecutive flicker faces always differ, so keying the angle off the
    // face value guarantees a visible wobble on every tick of the tumble.
    private var wobbleAngle: Double {
        guard viewModel.isRolling, !reduceMotion else { return 0 }
        return Double(viewModel.displayedFace) * 3 - 10.5
    }

    var body: some View {
        VStack(spacing: 48) {
            DieFaceView(face: viewModel.displayedFace, animateChanges: !reduceMotion)
                .frame(width: 180, height: 180)
                .foregroundStyle(.primary)
                .rotationEffect(.degrees(wobbleAngle))
                .scaleEffect(viewModel.isRolling && !reduceMotion ? 1.08 : 1)
                .animation(.spring(duration: 0.25, bounce: 0.5), value: wobbleAngle)
                .animation(.spring(duration: 0.3, bounce: 0.4), value: viewModel.isRolling)

            Text("Tap anywhere to roll")
                .font(.callout)
                .foregroundStyle(.secondary)
                .opacity(viewModel.rollCount == 0 ? 1 : 0)
                .animation(.easeOut(duration: 0.4), value: viewModel.rollCount == 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture { roll() }
        .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.rollCount)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Die")
        .accessibilityValue("Showing \(viewModel.displayedFace)")
        .accessibilityHint("Rolls the die")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { roll() }
    }

    private func roll() {
        Task {
            await viewModel.roll()
            AccessibilityNotification.Announcement("Rolled \(viewModel.displayedFace)").post()
        }
    }
}

#Preview {
    DiceRollScreen()
}
