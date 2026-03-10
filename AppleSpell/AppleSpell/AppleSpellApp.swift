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

            CommandGroup(after: .toolbar) {
                Button("Refresh Dictionary") {
                    viewModel.loadWords()
                }
                .keyboardShortcut("r", modifiers: .command)

                Divider()

                Button("Import Words...") {
                    viewModel.importWords()
                }
                .keyboardShortcut("i", modifiers: [.command, .shift])

                Button("Export Words...") {
                    viewModel.exportWords()
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])
            }
        }

        Settings {
            SettingsView(viewModel: viewModel)
        }
    }
}
