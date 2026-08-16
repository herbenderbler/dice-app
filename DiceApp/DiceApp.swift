import SwiftUI

// Named DiceRollApp rather than DiceApp: a type sharing the module's name
// makes qualified references (DiceApp.Foo) ambiguous.
@main
struct DiceRollApp: App {
    var body: some Scene {
        WindowGroup {
            DiceRollScreen()
        }
    }
}
