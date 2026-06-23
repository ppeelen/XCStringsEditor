# XCStringsEditor Integration Guide

This guide explains how to integrate the XCStringsEditor package into your own macOS or iOS application.

## Quick Start

### 1. Add XCStringsEditor to Your Package

In your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ppeelen/XCStringsEditor.git", from: "0.2.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: ["XCStringsEditor"]
    )
]
```

### 2. Import and Use

```swift
import SwiftUI
import XCStringsEditor

struct ContentView: View {
    @State var xcstringsData: XCStrings
    @State var configuration: EditorConfiguration

    var body: some View {
        XCStringsEditorView(data: xcstringsData, configuration: configuration)
    }
}
```

## Architecture Patterns

### Host App Owns File I/O

**Key principle:** The host application owns all file I/O operations. XCStringsEditor only edits in-memory data.

**Why:** Gives you flexibility in how files are stored, accessed, and persisted. You can:
- Load from different sources (file system, bundle, cloud storage)
- Implement custom save strategies (auto-save, manual save, incremental backup)
- Handle permissions and access control
- Manage file locking and concurrent access

**Pattern:**

```swift
// Host app loads file
let data = try Data(contentsOf: fileURL)
let decoder = JSONDecoder()
let xcstrings = try decoder.decode(XCStrings.self, from: data)

// Pass to editor
XCStringsEditorView(data: xcstrings, configuration: config)

// Host app saves edited data back
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
let jsonData = try encoder.encode(xcstrings)
try jsonData.write(to: fileURL)
```

### Configuration Injection

EditorConfiguration replaces direct UserDefaults access, enabling cleaner dependency injection.

**Pattern:**

```swift
let configuration = EditorConfiguration(
    currentLanguage: .english,
    baseLanguage: .english,
    translationService: .google,
    googleAPIKey: "your-api-key",
    deeplAPIKey: "",
    baiduAppID: "",
    baiduSecretKey: "",
    llmAPIKey: "",
    translateLaterItemsHidden: false,
    staleItemsHidden: false,
    dontTranslateItemsHidden: false
)

XCStringsEditorView(data: data, configuration: configuration)
```

**Important:** Never hardcode API keys. Load them from:
- Environment variables
- Configuration files
- Secure storage (Keychain)
- Runtime prompts

## State Management

### Bridging Host State with XCStringsEditor

XCStringsEditor uses an internal `@Observable AppModel` to manage editing state. To integrate with your host app's state management:

**Pattern 1: Direct Data Binding**

```swift
@State var xcstringsData: XCStrings
@State var editorConfiguration: EditorConfiguration

var body: some View {
    VStack {
        XCStringsEditorView(data: xcstringsData, configuration: editorConfiguration)

        Button("Save") {
            saveFile(xcstringsData)
        }
    }
}
```

The editor modifies `xcstringsData` in place. When user changes a translation, the state updates.

**Pattern 2: State Refresh After Edits**

If you need to detect when the user has made changes:

```swift
@State var xcstringsData: XCStrings
@State var hasUnsavedChanges = false

var body: some View {
    VStack {
        XCStringsEditorView(data: xcstringsData, configuration: config)

        HStack {
            Button("Save") {
                saveFile(xcstringsData)
                hasUnsavedChanges = false
            }
            .disabled(!hasUnsavedChanges)

            Button("Discard") {
                reloadData()
                hasUnsavedChanges = false
            }
        }
    }
    .onChange(of: xcstringsData) { _, _ in
        hasUnsavedChanges = true
    }
}
```

**Pattern 3: Multi-view Coordination**

For apps with multiple screens, use a shared environment object:

```swift
@main
struct MyApp: App {
    @State var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
    }
}

class AppState: ObservableObject {
    @Published var xcstringsData: XCStrings?
    @Published var editorConfiguration: EditorConfiguration?
    
    func loadFile(_ url: URL) throws {
        let data = try Data(contentsOf: url)
        self.xcstringsData = try JSONDecoder().decode(XCStrings.self, from: data)
    }
}

struct ContentView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        if let data = appState.xcstringsData, let config = appState.editorConfiguration {
            XCStringsEditorView(data: data, configuration: config)
        }
    }
}
```

## Configuration

### Translation Services

XCStringsEditor supports multiple translation services via the `translationService` property:

```swift
public enum TranslationService {
    case google     // Requires googleAPIKey
    case deepl      // Requires deeplAPIKey
    case baidu      // Requires baiduAppID and baiduSecretKey
    case llm        // Requires llmAPIKey
}
```

**Setup example:**

```swift
let config = EditorConfiguration(
    currentLanguage: .english,
    baseLanguage: .english,
    translationService: .deepl,  // Select service
    deeplAPIKey: ProcessInfo.processInfo.environment["DEEPL_API_KEY"] ?? "",
    // ... other fields
)
```

### Language Selection

The `currentLanguage` property controls which language the editor displays:

```swift
@State var selectedLanguage: Language = .english

// In your UI
Picker("Language", selection: $selectedLanguage) {
    ForEach(availableLanguages) { language in
        Text(language.localizedName).tag(language)
    }
}
.onChange(of: selectedLanguage) { _, newLanguage in
    // Update configuration
    configuration.currentLanguage = newLanguage
}
```

### Filtering and UI Preferences

Control which item states are visible:

```swift
EditorConfiguration(
    // ...
    translateLaterItemsHidden: UserDefaults.standard.bool(forKey: "hideTranslateLater"),
    staleItemsHidden: UserDefaults.standard.bool(forKey: "hideStale"),
    dontTranslateItemsHidden: UserDefaults.standard.bool(forKey: "hideDontTranslate")
)
```

## File I/O

### Loading .xcstrings Files

```swift
func loadXCStrings(from url: URL) throws -> XCStrings {
    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    return try decoder.decode(XCStrings.self, from: data)
}
```

### Saving Edited Data

```swift
func saveXCStrings(_ data: XCStrings, to url: URL) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let jsonData = try encoder.encode(data)
    try jsonData.write(to: url, options: .atomic)
}
```

**Best practices:**
- Use `.atomic` option to prevent corruption
- Sort keys for consistent diffs in version control
- Pretty-print for readability
- Handle file access errors gracefully

### Loading from Bundle

```swift
func loadBundledXCStrings(filename: String) throws -> XCStrings {
    guard let url = Bundle.main.url(forResource: filename, withExtension: "xcstrings") else {
        throw NSError(domain: "FileNotFound", code: -1)
    }
    return try loadXCStrings(from: url)
}
```

### Loading from Documents Directory

```swift
func loadFromDocuments(filename: String) throws -> XCStrings {
    let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentURL.appendingPathComponent(filename)
    return try loadXCStrings(from: fileURL)
}
```

## Edge Cases

### Unsaved Changes

Detect when user has modified translations:

```swift
@State var originalData: XCStrings
@State var editedData: XCStrings
@State var hasChanges = false

var body: some View {
    VStack {
        XCStringsEditorView(data: editedData, configuration: config)
    }
    .onChange(of: editedData) { _, _ in
        hasChanges = (editedData != originalData)
    }
    .onDisappear {
        if hasChanges {
            // Warn user or auto-save
        }
    }
}
```

### Language Switching

When user changes language selection:

```swift
@State var currentLanguage: Language = .english

var body: some View {
    VStack {
        Picker("Language", selection: $currentLanguage) {
            ForEach(languages) { lang in
                Text(lang.localizedName).tag(lang)
            }
        }

        if let data = xcstringsData {
            XCStringsEditorView(
                data: data,
                configuration: EditorConfiguration(
                    currentLanguage: currentLanguage,
                    // ...
                )
            )
        }
    }
    .onChange(of: currentLanguage) { _, _ in
        // Persist preference
        UserDefaults.standard.set(currentLanguage.code, forKey: "selectedLanguage")
    }
}
```

### Handling File Access Errors

```swift
func loadFile(from url: URL) {
    guard url.startAccessingSecurityScopedResource() else {
        showError("Cannot access file")
        return
    }

    defer { url.stopAccessingSecurityScopedResource() }

    do {
        let data = try loadXCStrings(from: url)
        self.xcstringsData = data
    } catch {
        if error is DecodingError {
            showError("Invalid .xcstrings format")
        } else {
            showError("Failed to load file: \(error.localizedDescription)")
        }
    }
}
```

### Missing Translation Services

Handle cases where user hasn't configured API keys:

```swift
let config = EditorConfiguration(
    translationService: .google,
    googleAPIKey: apiKey.isEmpty ? "" : apiKey,
    // ...
)

// In UI
if config.googleAPIKey.isEmpty {
    Text("⚠️ No Google API key configured. Auto-translate disabled.")
        .foregroundStyle(.orange)
}
```

### Concurrent File Access

If multiple processes might access the file:

```swift
func saveWithRetry(_ data: XCStrings, to url: URL, maxRetries: Int = 3) throws {
    var lastError: Error?
    
    for attempt in 0..<maxRetries {
        do {
            try saveXCStrings(data, to: url)
            return  // Success
        } catch {
            lastError = error
            if attempt < maxRetries - 1 {
                try await Task.sleep(for: .milliseconds(100 * (attempt + 1)))
            }
        }
    }
    
    throw lastError ?? NSError(domain: "SaveFailed", code: -1)
}
```

## Example Apps

Refer to the example apps for complete, working implementations:

- **macOS Example:** `Examples/ExampleApp/` — Desktop app with file picker and save
- **iOS Example:** `Examples/iOS/ExampleiOSApp/` — iOS app with document picker

Run either example to see integration patterns in action.

## Platform-Specific Notes

### macOS

Use `NSOpenPanel` and `NSSavePanel` for file selection:

```swift
let panel = NSOpenPanel()
panel.allowedContentTypes = [.json]
panel.canChooseDirectories = false

if panel.runModal() == .OK, let url = panel.url {
    loadFile(from: url)
}
```

### iOS

Use `UIDocumentPickerViewController` or SwiftUI's `.fileImporter()`:

```swift
.fileImporter(
    isPresented: $showFilePicker,
    allowedContentTypes: [.json],
    allowsMultipleSelection: false
) { result in
    if case .success(let urls) = result, let url = urls.first {
        loadFile(from: url)
    }
}
```

For iOS, also handle security-scoped resource access:

```swift
guard url.startAccessingSecurityScopedResource() else { return }
defer { url.stopAccessingSecurityScopedResource() }
```

## Troubleshooting

### "Cannot find 'XCStringsEditor' in scope"

Ensure the package is added to your target's dependencies in Package.swift and imported in files.

### Editor View Not Updating

The XCStringsEditorView takes `data` by value, not by reference. Make sure you're passing a state variable that SwiftUI observes:

```swift
// ✓ Correct - data is observed
@State var xcstringsData: XCStrings
XCStringsEditorView(data: xcstringsData, configuration: config)

// ✗ Wrong - passing constant
let data = XCStrings(...)
XCStringsEditorView(data: data, configuration: config)
```

### Translation Service Returns Errors

Check that:
1. API key is configured and valid
2. Network access is available
3. API quota hasn't been exceeded
4. Source language is different from target language

## API Reference

See `/CLAUDE.md` for complete API documentation and architecture overview.

For specific type information, refer to:
- `XCStringsEditorView` — Main embedding view
- `EditorConfiguration` — Configuration struct
- `XCStrings` — Data model
- `LocalizeItem` — Translation item
- `Language` — Supported languages

---

*Last updated: 2026-06-23*  
*XCStringsEditor v0.2.0*
