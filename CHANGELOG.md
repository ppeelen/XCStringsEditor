# Changelog

All notable changes to XCStringsEditor are documented in this file.

## [0.2.0] - 2026-06-23

### Added

- **Package Distribution** — XCStringsEditor is now a reusable Swift package
- **Public API** — Clean entry point via `XCStringsEditorView` for embedding in host applications
- **EditorConfiguration** — Dependency injection struct replacing UserDefaults for settings
- **macOS Example App** — Working example demonstrating real-world integration patterns
- **Integration Guide** — Comprehensive documentation for embedding in host apps
- **DocC Documentation** — Complete API documentation for all public types
- **WindowDelegate** — Public API for macOS window lifecycle management

### Changed

- **Architecture** — Separated app-specific code from reusable UI components
- **File I/O** — Host application now owns all file persistence (package is data-agnostic)
- **UserDefaults Access** — Replaced with EditorConfiguration dependency injection
- **Public API Surface** — Simplified to single entry point (XCStringsEditorView)
- **Translator Factory** — Now accepts configuration parameter instead of reading UserDefaults

### Fixed

- **WindowDelegate Environment** — Made public and properly integrated with SwiftUI environment
- **AppModel Decoupling** — Removed hard dependencies on AppDelegate and NSApplication
- **Translation Service Access** — Now fully configurable via EditorConfiguration
- **Environment Propagation** — Proper environment setup through view hierarchy

### Removed

- **Standalone App** — v0.2 is library-only (v0.1 was standalone macOS application)
- **AppDelegate Dependencies** — Package no longer requires NSApplication context
- **Direct UserDefaults Access** — All settings now passed via EditorConfiguration
- **File I/O Methods** — AppModel no longer handles file operations

### Known Limitations

- **Plural/Device Variations** — Display-only; add/remove in Xcode
- **Menu Commands** — Simplified in refactor; can be restored in future versions
- **Testing** — Manual testing only; automated test suite planned for v0.3
- **macOS Only** — iOS support planned for v0.3+

### Migration from v0.1

v0.2 is **not backward compatible** with v0.1. Choose an approach:

#### Option 1: Continue using v0.1
- Keep using v0.1 standalone macOS application
- No migration needed

#### Option 2: Integrate v0.2 package
1. Add XCStringsEditor as SPM dependency to your project
2. Create `EditorConfiguration` with your settings
3. Embed `XCStringsEditorView` in your app
4. Implement file I/O in your host app
5. See [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) for detailed patterns

### Dependencies

- **Swift:** 5.9+
- **Xcode:** 15.2+
- **macOS:** 14.0+
- **No external dependencies** — Pure SwiftUI, uses only Foundation and AppKit

---

## [0.1.0] - 2026-06-01

### Initial Release

Standalone macOS application for editing `.xcstrings` localization files.

#### Features

- Open, edit, and save `.xcstrings` files
- Multi-language translation interface
- Automatic translation (Google Translate, DeepL, Baidu, LLM)
- Reverse translation for quality checking
- Plural and device variation support (display-only)
- Item state management (new, translated, stale, needs review, etc.)
- Filtering and search
- Recent files and welcome screen
- Pure SwiftUI implementation

#### Requirements

- macOS 14.0+
- Xcode 15.2+

---

## Versioning

This project uses **Semantic Versioning**:

- **MAJOR** (0.x) — Breaking API changes
- **MINOR** (.x.) — New features, backward compatible
- **PATCH** (..x) — Bug fixes, backward compatible

## GitHub Releases

Binary releases and detailed release notes available on [GitHub Releases](https://github.com/ppeelen/XCStringsEditor/releases)

## Support

For issues, feature requests, or questions, please open an issue on [GitHub](https://github.com/ppeelen/XCStringsEditor/issues).
