import SwiftUI

@main
struct OuroborosApp: App {
    @StateObject private var engine = GameEngine()
    
    init() {
        print("DEBUG [OuroborosApp]: App started.")
        #if os(macOS)
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
        print("DEBUG [OuroborosApp]: Forced ActivationPolicy to .regular (Dock Icon) and activated app.")
        #endif
    }

    var body: some Scene {
        WindowGroup {
            GameView(engine: engine)
                .frame(minWidth: 400, idealWidth: 600, maxWidth: 800,
                       minHeight: 440, idealHeight: 640, maxHeight: 840)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}
