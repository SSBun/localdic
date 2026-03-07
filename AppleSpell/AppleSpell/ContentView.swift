import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var viewModel = DictionaryViewModel()
    @State private var newWord: String = ""

    var body: some View {
        ZStack {
            // Background - extends to all edges
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Search bar - with padding for traffic lights
                SearchBarView(searchText: $viewModel.searchText)
                    .padding(.horizontal, 20)
                    .padding(.top, 50)
                    .padding(.bottom, 8)

                // Word list
                WordListView(
                    words: viewModel.filteredWords,
                    onDelete: viewModel.removeWords
                )

                // Add word section
                AddWordView(newWord: $newWord) {
                    addWord()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                // Footer with action buttons
                HStack {
                    Text("\(viewModel.wordCount) words")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Button("Import") {
                        viewModel.importWords()
                    }
                    .buttonStyle(.borderless)

                    Button("Export") {
                        viewModel.exportWords()
                    }
                    .buttonStyle(.borderless)

                    Button("Refresh") {
                        viewModel.loadWords()
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
        }
        .frame(minWidth: 400, minHeight: 600)
        .alert("Error", isPresented: $viewModel.showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
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
}
