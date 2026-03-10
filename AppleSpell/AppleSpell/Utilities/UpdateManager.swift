//
//  UpdateManager.swift
//  AppleSpell
//
//  Created by caishilin on 2026/3/9.
//

import Foundation
import AppKit

// MARK: - GitHub Release Model

struct GitHubRelease: Codable {
    let tagName: String
    let name: String?
    let body: String?
    let htmlUrl: String
    let assets: [GitHubAsset]?

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case name
        case body
        case htmlUrl = "html_url"
        case assets
    }
}

struct GitHubAsset: Codable {
    let name: String
    let browserDownloadUrl: String

    enum CodingKeys: String, CodingKey {
        case name
        case browserDownloadUrl = "browser_download_url"
    }
}

// MARK: - Update Manager

@MainActor
final class UpdateManager: ObservableObject {
    static let shared = UpdateManager()

    @Published var updateStatus: UpdateStatus = .idle
    @Published var latestRelease: GitHubRelease?

    enum UpdateStatus: Equatable {
        case idle
        case checking
        case updateAvailable(version: String)
        case upToDate
        case error(String)
    }

    private let repoOwner = "ssbun"
    private let repoName = "localdic"

    var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    func checkForUpdates() async {
        updateStatus = .checking

        do {
            let url = URL(string: "https://api.github.com/repos/\(repoOwner)/\(repoName)/releases/latest")!
            var request = URLRequest(url: url)
            request.timeoutInterval = 10
            request.setValue("AppleSpell/\(currentVersion)", forHTTPHeaderField: "User-Agent")
            request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
            request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                updateStatus = .error("Invalid response")
                return
            }

            if httpResponse.statusCode == 404 {
                // No releases found or repo doesn't exist
                updateStatus = .upToDate
                return
            }

            guard httpResponse.statusCode == 200 else {
                updateStatus = .error("HTTP \(httpResponse.statusCode)")
                return
            }

            let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
            latestRelease = release

            let latestVersion = release.tagName
                .replacingOccurrences(of: "v", with: "")
                .replacingOccurrences(of: "V", with: "")

            if isNewerVersion(latest: latestVersion, current: currentVersion) {
                updateStatus = .updateAvailable(version: latestVersion)
            } else {
                updateStatus = .upToDate
            }
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost, .dnsLookupFailed:
                updateStatus = .error("No internet connection")
            case .timedOut:
                updateStatus = .error("Connection timed out")
            case .cannotFindHost, .cannotConnectToHost:
                updateStatus = .error("Cannot connect to server")
            case .badServerResponse:
                updateStatus = .error("Server error")
            default:
                updateStatus = .error("Network unavailable")
            }
        } catch {
            updateStatus = .error(error.localizedDescription)
        }
    }

    private func isNewerVersion(latest: String, current: String) -> Bool {
        let latestComponents = latest.split(separator: ".").compactMap { Int($0) }
        let currentComponents = current.split(separator: ".").compactMap { Int($0) }

        for i in 0..<max(latestComponents.count, currentComponents.count) {
            let latestPart = i < latestComponents.count ? latestComponents[i] : 0
            let currentPart = i < currentComponents.count ? currentComponents[i] : 0

            if latestPart > currentPart {
                return true
            } else if latestPart < currentPart {
                return false
            }
        }
        return false
    }

    func openReleasePage() {
        guard let release = latestRelease, let url = URL(string: release.htmlUrl) else { return }
        NSWorkspace.shared.open(url)
    }
}
