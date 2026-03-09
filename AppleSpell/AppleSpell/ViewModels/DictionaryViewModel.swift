import Foundation
import SwiftUI
import Combine

@MainActor
class DictionaryViewModel: ObservableObject {
    @Published var words: [String] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showingError: Bool = false

    var filteredWords: [String] {
        if searchText.isEmpty {
            return words.sorted()
        }
        return words
            .filter { $0.localizedCaseInsensitiveContains(searchText) }
            .sorted()
    }

    var wordCount: Int {
        words.count
    }

    init() {
        loadWords()
    }

    // MARK: - File Operations

    func loadWords() {
        isLoading = true
        do {
            words = try DictionaryService.fetchWords()
        } catch {
            showError(error.localizedDescription)
        }
        isLoading = false
    }

    func addWords(_ newWords: [String]) {
        let uniqueNewWords = newWords
            .flatMap { $0.components(separatedBy: CharacterSet(charactersIn: " ,")) }
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .filter { !words.contains($0) }

        guard !uniqueNewWords.isEmpty else { return }

        var updatedWords = words
        updatedWords.append(contentsOf: uniqueNewWords)

        saveWords(updatedWords)
    }

    func removeWords(at offsets: IndexSet) {
        let wordsToRemove = offsets.map { filteredWords[$0] }
        var updatedWords = words
        updatedWords.removeAll { wordsToRemove.contains($0) }

        saveWords(updatedWords)
    }

    func removeWord(_ word: String) {
        var updatedWords = words
        updatedWords.removeAll { $0 == word }

        saveWords(updatedWords)
    }

    private func saveWords(_ updatedWords: [String]) {
        do {
            try DictionaryService.saveWords(updatedWords)
            words = updatedWords
        } catch {
            showError(error.localizedDescription)
        }
    }

    // MARK: - Import/Export

    func importWords() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.plainText]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.message = "Select a text file to import words from"

        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            let importedWords = content
                .split(separator: "\n", omittingEmptySubsequences: true)
                .map(String.init)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }

            addWords(importedWords)
        } catch {
            showError("Failed to import file: \(error.localizedDescription)")
        }
    }

    func exportWords() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText]
        panel.nameFieldStringValue = "dictionary.txt"
        panel.message = "Choose a location to export words"

        guard panel.runModal() == .OK, let url = panel.url else { return }

        let content = words.sorted().joined(separator: "\n")

        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            showError("Failed to export file: \(error.localizedDescription)")
        }
    }

    // MARK: - Error Handling

    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}
