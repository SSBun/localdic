import Foundation

/// Service for managing the AppleSpell local dictionary file
enum DictionaryService {
    static let localDicPath: String = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Spelling/LocalDictionary")
        .path

    /// Fetch all words from the local dictionary
    static func fetchWords() throws -> [String] {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: localDicPath) else {
            return []
        }

        let content = try String(contentsOfFile: localDicPath, encoding: .utf8)
        let words = content
            .split(separator: "\n", omittingEmptySubsequences: true)
            .map(String.init)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        return words
    }

    /// Save words to the local dictionary
    /// Note: macOS automatically reloads the dictionary when the file changes
    static func saveWords(_ words: [String]) throws {
        let content = words.joined(separator: "\n")
        try content.write(toFile: localDicPath, atomically: true, encoding: .utf8)
    }
}

enum AppleSpellError: LocalizedError {
    case restartFailed(String)
    case fileNotFound
    case saveFailed(String)

    var errorDescription: String? {
        switch self {
        case .restartFailed(let message):
            return "Failed to restart AppleSpell: \(message)"
        case .fileNotFound:
            return "Dictionary file not found"
        case .saveFailed(let message):
            return "Failed to save dictionary: \(message)"
        }
    }
}
