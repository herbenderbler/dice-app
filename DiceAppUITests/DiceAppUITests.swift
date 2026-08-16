import XCTest

/// Launches the real app in the Simulator, rolls the die, and attaches
/// screenshots at each stage. CI exports the attachments from the result
/// bundle and uploads them as a workflow artifact, so every run leaves
/// visual evidence of the app working.
final class DiceAppUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testTapToRollCapturesScreenshots() throws {
        let app = XCUIApplication()
        app.launch()

        // The whole screen is one accessibility element: a button labeled
        // "Die" whose value reads "Showing N".
        let die = app.buttons["Die"]
        XCTAssertTrue(die.waitForExistence(timeout: 10), "Die should appear on launch")
        assertShowingAFace(die)
        attachScreenshot(of: app, named: "01-launch")

        die.tap()
        // Mid-flicker: the roll animation runs ~0.6 s, so 0.25 s in we
        // catch the tumble. Timing here only affects what the screenshot
        // shows, never pass/fail.
        Thread.sleep(forTimeInterval: 0.25)
        attachScreenshot(of: app, named: "02-rolling")

        Thread.sleep(forTimeInterval: 1.5)
        assertShowingAFace(die)
        attachScreenshot(of: app, named: "03-settled")

        // A second roll may legitimately land on the same face, so assert
        // only that the value is a valid face, never that it changed.
        die.tap()
        Thread.sleep(forTimeInterval: 2.0)
        assertShowingAFace(die)
        attachScreenshot(of: app, named: "04-second-roll")
    }

    private func assertShowingAFace(_ die: XCUIElement) {
        let value = die.value as? String ?? ""
        XCTAssertTrue(value.hasPrefix("Showing "), "Unexpected die value: \(value)")
        let face = Int(value.dropFirst("Showing ".count))
        XCTAssertNotNil(face, "Die value has no number: \(value)")
        XCTAssertTrue((1...6).contains(face ?? 0), "Face out of range: \(value)")
    }

    private func attachScreenshot(of app: XCUIApplication, named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        // Default lifetime deletes attachments when the test passes; we
        // want them precisely when it passes.
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
