import Accessibility
import SwiftUI

/// The app's single screen: the Candy Pop cube on a warm cream gradient,
/// with the entire screen acting as the roll button.
struct DiceRollScreen: View {
    @State private var viewModel = DiceRollViewModel()
    @State private var haptics = HapticsPlayer()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    private var palette: CandyPopTheme.Palette {
        CandyPopTheme.palette(for: colorScheme)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [palette.backgroundTop, palette.backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer(minLength: 0)

                DiceCubeView(
                    face: viewModel.displayedFace,
                    rollID: viewModel.rollCount,
                    reduceMotion: reduceMotion,
                    colorScheme: colorScheme
                )
                .aspectRatio(1, contentMode: .fit)
                .padding(.horizontal, 20)

                // Ground shadow: squashes and fades while the cube is
                // airborne, recovers on landing.
                Ellipse()
                    .fill(palette.shadow)
                    .frame(height: 26)
                    .padding(.horizontal, 96)
                    .blur(radius: 12)
                    .opacity(viewModel.isRolling && !reduceMotion ? 0.16 : 0.32)
                    .scaleEffect(viewModel.isRolling && !reduceMotion ? 0.72 : 1)
                    .animation(.easeOut(duration: 0.3), value: viewModel.isRolling)

                Spacer(minLength: 0)

                Text("Tap anywhere to roll")
                    .font(.system(.callout, design: .rounded, weight: .medium))
                    .foregroundStyle(palette.hint)
                    .opacity(viewModel.rollCount == 0 ? 1 : 0)
                    .animation(.easeOut(duration: 0.4), value: viewModel.rollCount == 0)
                    .padding(.bottom, 8)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { roll() }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Die")
        .accessibilityValue("Showing \(viewModel.displayedFace)")
        .accessibilityHint("Rolls the die")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { roll() }
    }

    private func roll() {
        guard !viewModel.isRolling else { return }
        haptics.playRoll(reduceMotion: reduceMotion)
        Task {
            await viewModel.roll()
            AccessibilityNotification.Announcement("Rolled \(viewModel.displayedFace)").post()
        }
    }
}

#Preview {
    DiceRollScreen()
}
