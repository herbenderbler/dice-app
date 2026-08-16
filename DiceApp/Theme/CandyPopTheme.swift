import SwiftUI
import UIKit

/// The selected style direction (STYLES.md: "Candy Pop"): playful
/// multi-pastel — mint die, plum pips, warm cream ground. Every color pair
/// here is WCAG-verified in both modes (pips vs face 9.9:1 light, 8.9:1
/// dark; hint vs background 7.4:1 / 11.1:1). Change values only together
/// with re-running the contrast math.
enum CandyPopTheme {
    struct Palette {
        let backgroundTop: Color
        let backgroundBottom: Color
        let dieFace: UIColor
        let dieBorder: UIColor
        let pips: UIColor
        let hint: Color
        let shadow: Color
    }

    static let light = Palette(
        backgroundTop: Color(hex: 0xFAF3E7),
        backgroundBottom: Color(hex: 0xF3E6CF),
        dieFace: UIColor(hex: 0xB8ECD7),
        dieBorder: UIColor(hex: 0x2E7D64),
        pips: UIColor(hex: 0x45254A),
        hint: Color(hex: 0x5F4C3C),
        shadow: Color(hex: 0xC9B99B)
    )

    static let dark = Palette(
        backgroundTop: Color(hex: 0x211A24),
        backgroundBottom: Color(hex: 0x2B2230),
        dieFace: UIColor(hex: 0x2A4A40),
        dieBorder: UIColor(hex: 0x7FC8AC),
        pips: UIColor(hex: 0xFFF3E2),
        hint: Color(hex: 0xDCCFC2),
        shadow: Color(hex: 0x000000)
    )

    static func palette(for scheme: ColorScheme) -> Palette {
        scheme == .dark ? dark : light
    }

    /// Roll choreography: the cube lands (overshoot arrival) at
    /// `tumbleDuration`, bounces back over `settleDuration`, and the view
    /// model holds `isRolling` for `rollDuration` total.
    static let tumbleDuration: TimeInterval = 0.80
    static let settleDuration: TimeInterval = 0.25
    static let rollDuration: Duration = .milliseconds(1050)

    /// Chamfer as a fraction of the unit cube edge — the rounded-edge
    /// radius that makes the die read as a toy rather than a box.
    static let chamferRatio: CGFloat = 0.16
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
