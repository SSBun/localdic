//
//  SettingsView.swift
//  AppleSpell
//
//  Created by caishilin on 2026/3/9.
//

import SwiftUI
import AppKit

// MARK: - Tab Enum

private enum SettingsTab: String, CaseIterable, Identifiable {
    case general = "General"
    case about = "About"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .general: return "gearshape"
        case .about: return "info.circle"
        }
    }
}

struct SettingsView: View {
    @StateObject private var viewModel: DictionaryViewModel
    @StateObject private var updateManager = UpdateManager.shared
    @State private var selectedTab: SettingsTab = .general

    init(viewModel: DictionaryViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            generalTabContent
                .tabItem { Label("General", systemImage: SettingsTab.general.icon) }
                .tag(SettingsTab.general)

            aboutTabContent
                .tabItem { Label("About", systemImage: SettingsTab.about.icon) }
                .tag(SettingsTab.about)
        }
        .frame(width: 400, height: 600)
    }

    // MARK: - Section Style

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
    }

    private func sectionDescription(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11))
            .foregroundStyle(.secondary)
    }

    private func pathLikeBackground(_ content: some View) -> some View {
        content
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(6)
    }

    // MARK: - General Tab

    private var generalTabContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Import/Export Section
                VStack(alignment: .leading, spacing: 10) {
                    sectionTitle("Import / Export")
                    sectionDescription("Import or export words from/to a text file.")

                    HStack(spacing: 12) {
                        Button(action: { viewModel.importWords() }) {
                            Label("Import", systemImage: "square.and.arrow.down")
                        }
                        .buttonStyle(.bordered)

                        Button(action: { viewModel.exportWords() }) {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.bordered)
                    }
                }

                Divider()

                // Dictionary Location Section
                VStack(alignment: .leading, spacing: 10) {
                    sectionTitle("Dictionary Location")
                    sectionDescription("The local dictionary file path.")

                    HStack(spacing: 8) {
                        pathLikeBackground(
                            Text(DictionaryService.localDicPath)
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                                .textSelection(.enabled)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        )

                        Button(action: { revealInFinder() }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundStyle(Color.accentColor)
                        }
                        .buttonStyle(.plain)
                        .help("Reveal in Finder")
                    }
                }

                Divider()

                // Word Count Section
                VStack(alignment: .leading, spacing: 10) {
                    sectionTitle("Statistics")
                    sectionDescription("Current dictionary statistics.")

                    HStack {
                        Text("Total words: \(viewModel.wordCount)")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)

                        Spacer()

                        Button(action: { viewModel.loadWords() }) {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(30)
        }
    }

    // MARK: - About Tab

    private var aboutTabContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // App Info Section
                VStack(alignment: .leading, spacing: 10) {
                    sectionTitle("About")
                    sectionDescription("AppleSpell is a tool for managing the macOS local dictionary.")
                }

                Divider()

                // Version Section
                VStack(alignment: .leading, spacing: 10) {
                    sectionTitle("Version")
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Version: \(updateManager.currentVersion) (\(updateManager.buildNumber))")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                            updateStatusView
                        }
                        Spacer()
                        Button("Check for Updates") {
                            Task {
                                await updateManager.checkForUpdates()
                            }
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .disabled(updateManager.updateStatus == .checking)
                    }
                }

                Divider()

                // Links Section
                VStack(alignment: .leading, spacing: 10) {
                    sectionTitle("Links")
                    HStack(spacing: 12) {
                        Button(action: { openGitHub() }) {
                            Label("GitHub", systemImage: "link")
                        }
                        .buttonStyle(.bordered)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(30)
        }
    }

    @ViewBuilder
    private var updateStatusView: some View {
        switch updateManager.updateStatus {
        case .idle:
            EmptyView()
        case .checking:
            HStack(spacing: 6) {
                ProgressView()
                    .scaleEffect(0.6)
                Text("Checking for updates...")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        case .updateAvailable(let version):
            HStack(spacing: 6) {
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundStyle(.green)
                Text("Update available: v\(version)")
                    .font(.system(size: 11))
                    .foregroundStyle(.green)
                Button("Download") {
                    updateManager.openReleasePage()
                }
                .buttonStyle(.link)
                .font(.system(size: 11))
            }
        case .upToDate:
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.blue)
                Text("You're up to date!")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        case .error(let message):
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text("Error: \(message)")
                    .font(.system(size: 11))
                    .foregroundStyle(.orange)
            }
        }
    }

    // MARK: - Actions

    private func revealInFinder() {
        let path = DictionaryService.localDicPath
        let url = URL(fileURLWithPath: path)
        NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: "")
    }

    private func openGitHub() {
        if let url = URL(string: "https://github.com/ssbun/localdic") {
            NSWorkspace.shared.open(url)
        }
    }
}

#Preview {
    SettingsView(viewModel: DictionaryViewModel())
        .frame(width: 620, height: 560)
}
