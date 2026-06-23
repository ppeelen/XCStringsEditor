<img src="XCStringsEditorIcon.png" width="128"  />

# XCStringsEditor

[![Platform](https://img.shields.io/badge/platform-macos-lightgrey.svg)]()
[![Made With](https://img.shields.io/badge/made_with-SwiftUI-orange.svg)]()

A Swift package for editing `.xcstrings` localization files introduced in Xcode 15.

## Overview

**v0.2.0** — Reusable package for embedding in your macOS applications.

This is a refactored version of the original [XCStringsEditor](https://github.com/junghooh/XCStringsEditor) by [JungHoon Noh](https://github.com/junghooh), transformed from a standalone macOS application into a reusable Swift package. You can now embed the editor directly into your own SwiftUI apps.

## Requirements

- macOS 14.0+
- Xcode 15.2+
- Swift 5.9+

## Features

- Open and edit `.xcstrings` localization files
- Multi-language support (35+ languages)
- Translate with Google Translate, DeepL, Baidu, or LLM services
- Reverse translation for quality checking
- Support plural and device variations (display-only)
- Filter items by state (new, translated, stale, needs review, etc.)
- Embed as a view in your own applications

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ppeelen/XCStringsEditor.git", from: "0.2.0")
]
```

Or in Xcode: File → Add Packages

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
            translationService: .google
        )
        
        XCStringsEditorView(data: xcstringsData, configuration: config)
            .environment(\.windowDelegate, windowDelegate)
    }
}
```

## Documentation

- [Integration Guide](INTEGRATION_GUIDE.md) — Patterns for embedding and state management
- [Architecture](CLAUDE.md) — Design and API reference
- [Example App](Examples/ExampleApp/) — Working macOS example
- API Documentation — Use Xcode's Documentation Viewer (⌘-⇧-D)

## Known Limitations

- Plural/device variations must be added in Xcode (not in the editor)
- macOS only

## License

XCStringsEditor is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Credits

**v0.2.0 (2026):** Refactored into a reusable Swift package.
- Architecture & implementation: Claude
- Review & refinement: Paul Peelen

**Original v0.1.0 (2024):** [JungHoon Noh](https://github.com/junghooh)

This v0.2.0 package is built from and based on the original XCStringsEditor application.

Icon by [xvector](https://www.freepik.com/) on Freepik
