import ArgumentParser
import Foundation
import Rainbow

// MARK: - LocalDic

@main
struct LocalDic: ParsableCommand {
    static var configuration: CommandConfiguration = .init(
        commandName: "localdic",
        abstract: "A tool for managing local dictionary on Mac.",
        usage: """
               \("localdic list".green)
               \("localdic learn".green) <word>
               \("localdic forget".green) <word>
               \("localdic --help".green)
               """,
        version: "0.1",
        subcommands: [
            List.self,
            Learn.self,
            Forget.self,
        ],
        helpNames: .shortAndLong
    )
    
    func run() throws {
        var command = try LocalDic.parseAsRoot(["--help"])
        try command.run()
    }
}

// MARK: - List

struct List: ParsableCommand {
    static var configuration: CommandConfiguration = .init(
        abstract: "List all words in the local dictionary on your Mac.",
        usage: """
        \("localdic list".green)
        """
    )
    
    func run() throws {
        let localWords = try FileTool.fetchWords()
        print("All words in the local dictionary.\n".green)
        for (i, word) in localWords.enumerated() {
            print("\(i): ".red + word)
        }
    }
}

// MARK: - Learn

struct Learn: ParsableCommand {
    static var configuration: CommandConfiguration = .init(
        abstract: "Save words to the local dictionary.",
        usage: """
            \("localdic learn".green) ffmpeg llvm
            """,
        helpNames: .shortAndLong
    )
    
    @Argument(help: "Input \("words".green) that you want to perform.")
    var words: [String]
    
    
    func run() throws {
        var localWords = try FileTool.fetchWords()
        let uniqueWords: [String] = Set(words).filter { !localWords.contains($0) }
        localWords.append(contentsOf: uniqueWords)
        try FileTool.override(words: localWords)
        try restartAppleSpellService()
        print("Words below are added successfully.\n".green)
        for word in localWords {
            print("\(word)".red)
        }
    }
}

// MARK: - Forget

struct Forget: ParsableCommand {
    
    static var configuration: CommandConfiguration = .init(
        abstract: "Remove words from the local dictionary.",
        usage: """
            \("localdic forget".green) llvm ffmpeg    :remove words with strings
            \("localdic forget".green) 2 6            :remove words with indexes that you can check executing \("localdic list".green)
            \("localdic forget".green) 2 llvm         :remove words by mixing strings and indexes.
            """
    )
    
    @Argument(help: "Input \("words".green) or \("indexes".green) that you want to remove.")
    var words: [String]
    
    func run() throws {
        var localWords = try FileTool.fetchWords()
        var removedWords: Set<String> = []
        for word in words {
            if let index = Int(word), (0 ..< localWords.count).contains(index) {
                removedWords.insert(localWords[index])
            } else {
                removedWords.insert(word)
            }
        }
        localWords.removeAll(where: removedWords.contains(_:))
        try FileTool.override(words: localWords)
        try restartAppleSpellService()
        print("Words below are removed successfully.\n".green)
        for word in removedWords {
            print("\(word)".red)
        }
    }
}

// MARK: - FileTool

enum FileTool {
    static let localDicPath: String = FileManager.default.homeDirectoryForCurrentUser.relativePath + "/Library/Spelling/LocalDictionary"
    
    static func fetchWords() throws -> [String] {
        let content = try String(contentsOfFile: localDicPath)
        return content.split(separator: "\n").map(String.init)
    }
    
    static func override(words: [String]) throws {
        let content = words.joined(separator: "\n")
        try content.write(toFile: localDicPath, atomically: true, encoding: .utf8)
    }
}

func restartAppleSpellService() throws {
    guard case let .failure(errorMessage) = executeShellCommand(command: "killall -KILL AppleSpell") else { return }
    
    if errorMessage == "No matching processes belonging to you were found" { return }
    
    throw """
          \("Failed to restart AppleSpell service:".red)
          \(errorMessage.red)
          """
}

@discardableResult
func executeShellCommand(command: String) -> Result<String, String> {
    let process = Process()
    process.launchPath = "/bin/bash"
    process.arguments = ["-c", command]
    
    let outputPipe = Pipe()
    process.standardOutput = outputPipe
    let errorPipe = Pipe()
    process.standardError = errorPipe
    
    process.launch()
    process.waitUntilExit()
    
    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let outputString = String(data: outputData, encoding: .utf8)
    
    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    let errorString = String(data: errorData, encoding: .utf8)
    
    if let errorString, !errorString.isEmpty {
        return .failure(errorString.trimmingCharacters(in: .newlines))
    }
    
    return .success(outputString?.trimmingCharacters(in: .newlines) ?? "")
}

// MARK: - String + Error

extension String: Error {}
