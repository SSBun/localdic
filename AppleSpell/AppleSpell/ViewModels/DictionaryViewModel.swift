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
    @Published var showingDeleteConfirmation: Bool = false
    @Published var pendingDeleteWords: [String] = []

    // Cached sorted words to avoid repeated sorting
    @Published private var sortedWordsCache: [String] = []

    private var cancellables = Set<AnyCancellable>()
    private var isSaving: Bool = false

    var filteredWords: [String] {
        if searchText.isEmpty {
            // Return cached sorted words
            return sortedWordsCache
        }
        return sortedWordsCache
            .filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var wordCount: Int {
        words.count
    }

    init() {
        // Observe changes to words and update cache
        $words
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newWords in
                self?.sortedWordsCache = newWords.sorted()
            }
            .store(in: &cancellables)

        loadWords()
    }

    // MARK: - File Operations

    func loadWords() {
        guard !isLoading else { return }

        isLoading = true
        do {
            let fetchedWords = try DictionaryService.fetchWords()
            words = fetchedWords
        } catch {
            showError("Failed to load dictionary: \(error.localizedDescription)")
        }
        isLoading = false
    }

    func addWords(_ newWords: [String]) {
        guard !newWords.isEmpty else { return }

        let uniqueNewWords = newWords
            .flatMap { $0.components(separatedBy: CharacterSet(charactersIn: " ,")) }
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .filter { !words.contains($0) }

        guard !uniqueNewWords.isEmpty else {
            // All words were duplicates - could notify user
            return
        }

        var updatedWords = words
        updatedWords.append(contentsOf: uniqueNewWords)

        saveWords(updatedWords)
    }

    func removeWords(at offsets: IndexSet) {
        let wordsToRemove = offsets.map { filteredWords[$0] }
        requestDeleteConfirmation(words: wordsToRemove)
    }

    func removeWord(_ word: String) {
        requestDeleteConfirmation(words: [word])
    }

    func confirmDelete() {
        let wordsToRemove = pendingDeleteWords
        pendingDeleteWords = []
        showingDeleteConfirmation = false

        var updatedWords = words
        updatedWords.removeAll { wordsToRemove.contains($0) }
        saveWords(updatedWords)
    }

    func cancelDelete() {
        pendingDeleteWords = []
        showingDeleteConfirmation = false
    }

    private func requestDeleteConfirmation(words: [String]) {
        pendingDeleteWords = words
        showingDeleteConfirmation = true
    }

    private func saveWords(_ updatedWords: [String]) {
        guard !isSaving else { return }

        isSaving = true
        do {
            try DictionaryService.saveWords(updatedWords)
            words = updatedWords
        } catch {
            showError("Failed to save dictionary: \(error.localizedDescription)")
        }
        isSaving = false
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
