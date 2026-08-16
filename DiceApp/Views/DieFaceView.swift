import SwiftUI

/// One face of a d6, rendered with the built-in SF Symbols die faces
/// (`die.face.1` … `die.face.6`) so it stays crisp at any size and adapts
/// to light/dark mode for free.
struct DieFaceView: View {
    let face: Int
    var animateChanges = true

    var body: some View {
        Image(systemName: "die.face.\(face)")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .symbolRenderingMode(.hierarchical)
            .contentTransition(animateChanges ? .symbolEffect(.replace) : .identity)
    }
}

#Preview {
    DieFaceView(face: 5)
        .frame(width: 180, height: 180)
        .padding()
}
