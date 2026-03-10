import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject private var viewModel: DictionaryViewModel
    @State private var newWord: String = ""
    @FocusState private var isSearchFocused: Bool
    @FocusState private var isAddWordFocused: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background - blur effect fills entire window
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // Custom top bar - aligned to top of screen
                HStack {
                    Spacer()

                    Text("AppleSpell")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()
                }
                .frame(height: 28)
                .frame(maxWidth: .infinity)
                .background(Color.clear)

                // Search bar
                SearchBarView(searchText: $viewModel.searchText)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 8)

                // Word list - fills middle space
                WordListView(
                    words: viewModel.filteredWords,
                    onDelete: viewModel.removeWords,
                    onRemove: viewModel.removeWord
                )

                // Add word section
                AddWordView(newWord: $newWord) {
                    addWord()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                // Footer with word count and refresh
                HStack {
                    Text("\(viewModel.wordCount) words")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Button(action: {
                        viewModel.loadWords()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 12, weight: .medium))
                            .rotationEffect(.degrees(viewModel.isLoading ? 360 : 0))
                            .animation(viewModel.isLoading ? .linear(duration: 0.5).repeatForever(autoreverses: false) : .default, value: viewModel.isLoading)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut("r", modifiers: .command)
                    .help("Refresh word list (Cmd+R)")
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
            .frame(maxHeight: .infinity)
            .edgesIgnoringSafeArea(.top)
        }
        .frame(minWidth: 400, minHeight: 600)
        .alert("Error", isPresented: $viewModel.showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
        .confirmationDialog(
            "Remove Words",
            isPresented: $viewModel.showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Remove", role: .destructive) {
                viewModel.confirmDelete()
            }
            Button("Cancel", role: .cancel) {
                viewModel.cancelDelete()
            }
        } message: {
            if viewModel.pendingDeleteWords.count == 1 {
                Text("Are you sure you want to remove \"\(viewModel.pendingDeleteWords[0])\" from your dictionary?")
            } else {
                Text("Are you sure you want to remove \(viewModel.pendingDeleteWords.count) words from your dictionary?")
            }
        }
        .onAppear {
            isSearchFocused = true
        }
    }

    private func addWord() {
        let trimmed = newWord.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        viewModel.addWords([trimmed])
        newWord = ""
    }
}

// MARK: - Visual Effect View
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.wantsLayer = true
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

#Preview {
    ContentView()
        .environmentObject(DictionaryViewModel())
}
