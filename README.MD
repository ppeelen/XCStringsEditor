<img src="XCStringsEditorIcon.png" width="128"  />

# XCStringsEditor

[![Platform](https://img.shields.io/badge/platform-macos-lightgrey.svg)]()
[![Swift](https://img.shields.io/badge/swift-5.9+-orange.svg)]()
[![License](https://img.shields.io/badge/license-MIT-green.svg)]()

A reusable Swift package for embedding `.xcstrings` localization file editing directly into your macOS applications.

## Overview

XCStringsEditor eliminates the need for a separate localization tool. Embed the editor as a SwiftUI view in your app to give users or translators a dedicated interface for managing translations across multiple languages.

**v0.2.0 is a package release** — suitable for embedding in host applications. If you need the standalone macOS application, see the [releases page](https://github.com/ppeelen/XCStringsEditor/releases) for v0.1.

## Key Features

- **Embed in Your App** — Use `XCStringsEditorView` to add localization editing directly to your application
- **Multi-Language Support** — Edit translations for 35+ languages with full locale support
- **Automatic Translation** — Translate via Google Translate, DeepL, Baidu, or custom LLM services
- **Quality Control** — Reverse translation and state management (new, translated, stale, needs review, etc.)
- **Flexible State Management** — Host app controls file I/O, state, and credentials via dependency injection
- **Pure SwiftUI** — No external dependencies, integrates seamlessly with modern Swift apps

## Installation

Add to your `Package.swift`:

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

Or in Xcode: File → Add Packages → Enter package URL

## Quick Start

```swift
import SwiftUI
import XCStringsEditor

struct ContentView: View {
    @State var xcstringsData: XCStrings
    @State var windowDelegate = WindowDelegate()
    
    var body: some View {
        let config = EditorConfiguration(
            baseLanguage: .english,
            currentLanguage: .english,
            translationService: .google,
            googleAPIKey: loadAPIKey()
        )
        
        XCStringsEditorView(data: xcstringsData, configuration: config)
            .environment(\.windowDelegate, windowDelegate)
    }
}
```

## Requirements

- **Swift:** 5.9+
- **Xcode:** 15.2+
- **Platform:** macOS 14.0+

## Documentation

- **[Integration Guide](INTEGRATION_GUIDE.md)** — Comprehensive patterns for state management, file I/O, and configuration
- **[Architecture Overview](CLAUDE.md)** — Design decisions and package structure
- **[Example App](Examples/ExampleApp/)** — Working macOS example demonstrating real-world integration
- **API Documentation** — Use Xcode's Documentation Viewer (⌘-⇧-D) for complete API reference

## Features in Detail

✅ **Core Editing**
- Open and edit `.xcstrings` JSON files
- Multi-language translation interface
- Real-time state tracking

✅ **Translation Services**
- Google Translate (requires API key)
- DeepL (requires API key)
- Baidu Translate (requires API credentials)
- Custom LLM services (requires API key)
- Reverse translation for quality checking

✅ **State Management**
- Item states: new, translated, stale, needs review, needs work, translate later, don't translate
- Filtering by state
- Search and sort capabilities
- Language-specific filtering preferences

✅ **Plural & Device Variations**
- Display plural and device variations (added in Xcode)
- Note: Adding/removing variations requires Xcode

## Integration Pattern

XCStringsEditor follows a **host-owns-data** pattern:

1. **Host App** loads `.xcstrings` file from disk
2. **Host App** creates `EditorConfiguration` with credentials
3. **Host App** embeds `XCStringsEditorView` with data + configuration
4. **User** edits translations in the view
5. **Host App** saves modified data back to disk

This design gives you complete control over file I/O, state management, and credential handling.

See [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) for detailed patterns and examples.

## Known Limitations

- **Plural/Device Variations** — Variants must be added/removed in Xcode (not in editor)
- **Testing** — Manual testing only; automated tests planned for v0.3
- **macOS Only** — iOS support planned for future releases

## Roadmap

**v0.2.0** (Current)
- ✅ Package extraction and reusability
- ✅ Embed view (XCStringsEditorView)
- ✅ Configuration dependency injection
- ✅ Integration examples and guides

**v0.3+** (Planned)
- [ ] Automated test coverage
- [ ] iOS support
- [ ] Direct .xcodeproj editing
- [ ] Xcode project integration tools

## Contributing

Contributions are welcome! Please open an issue or pull request on [GitHub](https://github.com/ppeelen/XCStringsEditor).

## Support

Having issues? Check the [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) troubleshooting section or open an issue on GitHub.

## License

XCStringsEditor is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Project History

**v0.2.0 (June 2026):** Transformation from standalone app to reusable package

This version represents a significant architectural refactor from a standalone macOS application to a distributable Swift package. The refactoring includes:

- Architecture decoupling and separation of concerns
- Public API design (XCStringsEditorView, EditorConfiguration)
- File I/O delegation to host applications
- Configuration dependency injection
- Complete API documentation (DocC)
- Integration patterns and examples
- Release preparation and packaging

**Implementation:** Architecture planning, design, and initial implementation by Claude with manual review and refinement by Paul Peelen. All code changes follow the established patterns and project structure.

**v0.1.0 (June 2024):** Original standalone macOS application

## Acknowledgements

Built with [SwiftUI](https://developer.apple.com/swiftui/) and inspired by the localization workflows of Xcode 15+.

Pencil icon by [xvector](https://www.freepik.com/) on Freepik

**Development:** Architecture planning, implementation, and documentation support by Claude. Manual review, testing, and refinement by Paul Peelen.
