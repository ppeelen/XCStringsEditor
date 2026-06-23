//
//  XCStringEditorApp.swift
//  XCStringEditor
//
//  Created by JungHoon Noh on 1/20/24.
//  Refactored to use XCStringsEditorView

import SwiftUI

extension Notification.Name {
    static let findCommand = Notification.Name("findCommand")
}

struct XCStringEditorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var xcstringsData: XCStrings?
    @State private var editorConfiguration: EditorConfiguration?
    @State private var fileURL: URL?
    @State private var fileHandler = FileHandler()

    var body: some Scene {
        Window("XCStringsEditor", id: "main") {
            Group {
                if let xcstringsData = xcstringsData, let editorConfiguration = editorConfiguration {
                    // Show editor
                    XCStringsEditorView(data: xcstringsData, configuration: editorConfiguration)
                        .background(FileDropView { url in
                            loadFile(url)
                        })
                        .environment(appDelegate.windowDelegate)
                        .onChange(of: xcstringsData) { _, newData in
                            // Auto-save when data changes
                            if let fileURL = fileURL {
                                Task {
                                    try? await fileHandler.saveXCStrings(newData, to: fileURL)
                                }
                            }
                        }
                } else {
                    // Show welcome screen
                    WelcomeView(onFileSelected: { url in
                        loadFile(url)
                    })
                        .background(FileDropView { url in
                            loadFile(url)
                        })
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .receivedOpenURLsNotification), perform: { newValue in
                guard let urls = newValue.userInfo?["urls"] as? [URL], let url = urls.first else {
                    return
                }
                loadFile(url)
            })
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Divider()
                Button("Open") {
                    open()
                }
                .keyboardShortcut("o", modifiers: [.command])

                Menu("Open Recent") {
                    let recents = (UserDefaults.standard.array(forKey: "RecentFiles") as? [String])?.map { URL(filePath: $0) } ?? [URL]()
                    if recents.isEmpty == false {
                        ForEach(recents.reversed(), id: \.self) { url in
                            Button(url.lastPathComponent) {
                                loadFile(url)
                            }
                        }
                        Divider()
                        Button("Clear Menu") {
                            UserDefaults.standard.removeObject(forKey: "RecentFiles")
                        }
                    }
                }
            }
        }

        if #available(macOS 15.0, *) {
            Window("Welcome", id: "welcome") {
                WelcomeView(onFileSelected: { url in
                    loadFile(url)
                })
            }
            .windowStyle(.hiddenTitleBar)
            .windowResizability(.contentSize)
            .defaultLaunchBehavior(.presented)
        }

        Settings {
            SettingsView()
        }
    }

    func open() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.json]
        if panel.runModal() == .OK {
            if let url = panel.url {
                loadFile(url)
            }
        }
    }

    private func loadFile(_ url: URL) {
        Task {
            do {
                let data = try await fileHandler.loadXCStrings(from: url)
                let config = EditorConfiguration(
                    baseLanguage: data.sourceLanguage,
                    currentLanguage: Language(code: UserDefaults.standard.string(forKey: "lastLanguage") ?? data.sourceLanguage.code) ?? data.sourceLanguage,
                    translationService: TranslationService(rawValue: UserDefaults.standard.string(forKey: "translationService") ?? "google") ?? .google,
                    googleAPIKey: UserDefaults.standard.string(forKey: "googleAPIKey"),
                    deeplAPIKey: UserDefaults.standard.string(forKey: "deeplAPIKey"),
                    baiduAPIKey: UserDefaults.standard.string(forKey: "baiduAPIKey"),
                    llmAPIKey: UserDefaults.standard.string(forKey: "llmAPIKey")
                )

                // Update recent files
                var recents = UserDefaults.standard.array(forKey: "RecentFiles") as? [String] ?? []
                if let index = recents.firstIndex(of: url.path(percentEncoded: false)) {
                    recents.remove(at: index)
                }
                recents.append(url.path(percentEncoded: false))
                if recents.count > 15 {
                    recents.removeFirst(recents.count - 15)
                }
                UserDefaults.standard.set(recents, forKey: "RecentFiles")

                self.xcstringsData = data
                self.editorConfiguration = config
                self.fileURL = url
            } catch {
                print("Failed to load file: \(error)")
            }
        }
    }
}
