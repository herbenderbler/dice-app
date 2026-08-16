import SceneKit
import SwiftUI

/// A chamfered SceneKit cube rendered flat (unlit materials) so it keeps
/// the Candy Pop toy look. Each roll runs a keyframed diagonal tumble —
/// one full turn on both axes with a small overshoot and bounce-back —
/// that always ends with the view model's already-chosen face toward the
/// camera. Touches pass through to the SwiftUI tap gesture behind it.
struct DiceCubeView: UIViewRepresentable {
    let face: Int
    let rollID: Int
    let reduceMotion: Bool
    let colorScheme: ColorScheme

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.antialiasingMode = .multisampling4X
        view.isUserInteractionEnabled = false
        view.scene = context.coordinator.scene
        context.coordinator.applyPalette(CandyPopTheme.palette(for: colorScheme))
        context.coordinator.appliedScheme = colorScheme
        context.coordinator.showInstantly(face: face)
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        let coordinator = context.coordinator
        if coordinator.appliedScheme != colorScheme {
            coordinator.applyPalette(CandyPopTheme.palette(for: colorScheme))
            coordinator.appliedScheme = colorScheme
        }
        if coordinator.lastRollID != rollID {
            coordinator.lastRollID = rollID
            coordinator.tumble(to: face, reduceMotion: reduceMotion)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    @MainActor
    final class Coordinator {
        let scene: SCNScene
        var appliedScheme: ColorScheme?
        var lastRollID = 0

        private let dieNode: SCNNode
        private let box: SCNBox

        // SCNBox material slot order: front(+Z), right(+X), back(−Z),
        // left(−X), top(+Y), bottom(−Y). Faces assigned so opposite faces
        // sum to 7, like a real die.
        private static let faceForSlot = [1, 2, 6, 5, 3, 4]

        private static let pipLayout: [Int: [(CGFloat, CGFloat)]] = [
            1: [(0, 0)],
            2: [(-1, -1), (1, 1)],
            3: [(-1, -1), (0, 0), (1, 1)],
            4: [(-1, -1), (1, -1), (-1, 1), (1, 1)],
            5: [(-1, -1), (1, -1), (0, 0), (-1, 1), (1, 1)],
            6: [(-1, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (1, 1)],
        ]

        init() {
            box = SCNBox(
                width: 1, height: 1, length: 1,
                chamferRadius: CandyPopTheme.chamferRatio
            )
            box.chamferSegmentCount = 24
            dieNode = SCNNode(geometry: box)

            scene = SCNScene()
            scene.rootNode.addChildNode(dieNode)

            let camera = SCNCamera()
            camera.fieldOfView = 28
            let cameraNode = SCNNode()
            cameraNode.camera = camera
            cameraNode.position = SCNVector3(0, 0, 3.4)
            scene.rootNode.addChildNode(cameraNode)
        }

        func applyPalette(_ palette: CandyPopTheme.Palette) {
            box.materials = Self.faceForSlot.map { face in
                let material = SCNMaterial()
                material.lightingModel = .constant
                material.diffuse.contents = Self.faceImage(face: face, palette: palette)
                return material
            }
        }

        func showInstantly(face: Int) {
            dieNode.removeAllActions()
            dieNode.eulerAngles = Self.restEuler(for: face)
        }

        func tumble(to face: Int, reduceMotion: Bool) {
            guard !reduceMotion else {
                showInstantly(face: face)
                return
            }
            let target = Self.restEuler(for: face)
            let spin = Float(2 * Double.pi)
            let overshoot: Float = 0.14

            dieNode.removeAllActions()
            let tumble = SCNAction.rotateTo(
                x: CGFloat(target.x + spin + overshoot),
                y: CGFloat(target.y + spin + overshoot),
                z: 0,
                duration: CandyPopTheme.tumbleDuration,
                usesShortestUnitArc: false
            )
            tumble.timingMode = .easeOut
            let settle = SCNAction.rotateTo(
                x: CGFloat(target.x + spin),
                y: CGFloat(target.y + spin),
                z: 0,
                duration: CandyPopTheme.settleDuration,
                usesShortestUnitArc: false
            )
            settle.timingMode = .easeInEaseOut
            dieNode.runAction(.sequence([tumble, settle])) { [weak self] in
                // Normalize so euler values don't grow without bound
                // across rolls.
                Task { @MainActor in
                    self?.dieNode.eulerAngles = target
                }
            }
        }

        /// Cube orientation that brings `face` toward the camera (+Z).
        private static func restEuler(for face: Int) -> SCNVector3 {
            switch face {
            case 2: SCNVector3(0, -Float.pi / 2, 0)
            case 3: SCNVector3(Float.pi / 2, 0, 0)
            case 4: SCNVector3(-Float.pi / 2, 0, 0)
            case 5: SCNVector3(0, Float.pi / 2, 0)
            case 6: SCNVector3(0, Float.pi, 0)
            default: SCNVector3(0, 0, 0)
            }
        }

        private static func faceImage(face: Int, palette: CandyPopTheme.Palette) -> UIImage {
            let side: CGFloat = 512
            let size = CGSize(width: side, height: side)
            return UIGraphicsImageRenderer(size: size).image { context in
                palette.dieFace.setFill()
                context.fill(CGRect(origin: .zero, size: size))

                palette.dieBorder.setStroke()
                let inset: CGFloat = 30
                let border = UIBezierPath(
                    roundedRect: CGRect(x: inset, y: inset, width: side - 2 * inset, height: side - 2 * inset),
                    cornerRadius: 88
                )
                border.lineWidth = 6
                border.stroke()

                palette.pips.setFill()
                let pipDiameter = side * 0.165
                let offset = side * 0.26
                for (dx, dy) in pipLayout[face] ?? [] {
                    let center = CGPoint(x: side / 2 + dx * offset, y: side / 2 + dy * offset)
                    UIBezierPath(ovalIn: CGRect(
                        x: center.x - pipDiameter / 2,
                        y: center.y - pipDiameter / 2,
                        width: pipDiameter,
                        height: pipDiameter
                    )).fill()
                }
            }
        }
    }
}
