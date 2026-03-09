import SwiftUI
import AppKit

@main
struct AppleSpellApp: App {
    @StateObject private var viewModel = DictionaryViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }

        Settings {
            SettingsView(viewModel: viewModel)
        }
    }
}
