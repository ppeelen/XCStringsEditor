# XCStringsEditor Example Application

This example demonstrates how to embed XCStringsEditor as a package in your own macOS application.

## Integration Pattern

The example shows the recommended integration pattern:

1. **Load .xcstrings file** — Your app loads the JSON file and decodes it into an `XCStrings` object
2. **Create configuration** — Set up `EditorConfiguration` with language settings and API keys
3. **Embed the view** — Use `XCStringsEditorView` in your UI, passing data and configuration

### Basic Usage

```swift
import SwiftUI
import XCStringsEditor

@main
struct MyApp: App {
    @State private var xcstringsData: XCStrings?
    @State private var configuration: EditorConfiguration?

    var body: some Scene {
        WindowGroup {
            if let data = xcstringsData, let config = configuration {
                XCStringsEditorView(data: data, configuration: config)
            } else {
                VStack {
                    Button("Open Strings File") {
                        loadFile()
                    }
                }
            }
        }
    }

    func loadFile() {
        // Load .xcstrings JSON file
        let fileManager = FileManager.default
        let url = /* path to .xcstrings file */
        let data = try? Data(contentsOf: url)
        let xcstrings = try? JSONDecoder().decode(XCStrings.self, from: data!)

        // Create configuration
        let config = EditorConfiguration(
            baseLanguage: .english,
            currentLanguage: .english,
            translationService: .google,
            googleAPIKey: "your-api-key"  // Host app manages keys
        )

        self.xcstringsData = xcstrings
        self.configuration = config
    }
}
```

## Key Concepts

### Separation of Concerns

- **Package (XCStringsEditor):** Editing UI and translation logic
- **Host App:** File I/O, persistence, API key management, UI orchestration

### Data Flow

```
Host App
├── Load .xcstrings file → XCStrings object
├── Create EditorConfiguration
└── Pass to XCStringsEditorView
    ├── User edits in UI
    └── Data mutations reflected in XCStrings object
└── Save XCStrings back to file (host responsibility)
```

### Configuration

`EditorConfiguration` controls:
- Base and current language
- Translation service selection (Google, DeepL, Baidu, LLM)
- API keys for translation services
- UI preferences (which states to hide/show)

## Running the Example

### Setup

1. Ensure XCStringsEditor package builds:
   ```bash
   swift build
   ```

2. Create/prepare a sample .xcstrings file
3. Update `ExampleApp.swift` to point to your file
4. Run the app in Xcode

### In Xcode

1. Open `XCStringsEditor.xcodeproj` (the main project)
2. Build the XCStringsEditor scheme
3. Build the ExampleApp scheme
4. Run the app

## Customization Points

### Change Translation Service

```swift
let config = EditorConfiguration(
    baseLanguage: .english,
    currentLanguage: .english,
    translationService: .deepL,  // or .baidu, .llm
    deeplAPIKey: "your-key"
)
```

### Change Current Language

```swift
// User selects different language
configuration?.currentLanguage = .spanish
```

### Persist Changes

```swift
// After user edits:
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
let jsonData = try encoder.encode(xcstringsData)
try jsonData.write(to: fileURL)
```

## Troubleshooting

### "Cannot find module 'XCStringsEditor'"

Ensure:
- Package.swift is at the project root
- XCStringsEditor target is built first
- Your example app declares the package dependency correctly

### Translation service not working

Ensure:
- API key is set in EditorConfiguration
- Credentials are valid and have required permissions
- Network connectivity is available

## Files in This Example

- `ExampleApp.swift` — Main app demonstrating integration pattern
- `README.md` — This file

---

For more details on the package API, see the main project's [CLAUDE.md](../CLAUDE.md).
