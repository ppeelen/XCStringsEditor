# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**XCStringsEditor** is a macOS application built with SwiftUI that edits `.xcstrings` localization files (introduced in Xcode 15). It provides a dedicated UI for managing translations across multiple languages, with support for automatic translation via Google Translate, DeepL, Baidu, and LLM APIs.

**Requirements:** macOS 14.0+, Xcode 15.2+

## Build and Run Commands

```bash
# Open project in Xcode
open XCStringsEditor.xcodeproj

# Build from command line (Intel/Apple Silicon)
xcodebuild -project XCStringsEditor.xcodeproj -scheme XCStringsEditor -configuration Release

# Run the app (after opening in Xcode)
# Cmd+R in Xcode, or use:
xcodebuild -project XCStringsEditor.xcodeproj -scheme XCStringsEditor -configuration Debug -derivedDataPath /tmp/xcode-build
```

There are no automated tests currently in the project. For verifying changes, run the app in Xcode and manually test the affected feature.

## Code Architecture

### Core Data Models

**AppModel** (`Model/AppModel.swift`)
- Central `@Observable` class managing all application state
- Handles file I/O (load/save `.xcstrings` files)
- Manages language selection, filtering, searching, and sorting
- Tracks modifications and coordinates UI updates
- Contains filtering logic (by state, search text, language)
- Integrates with translation services via `TranslatorFactory`

**LocalizeItem** (`Model/LocalizeItem.swift`)
- Represents a single localizable string with versioning across languages
- Key properties: `key`, `sourceString`, `translation`, `pluralType`, `deviceType`
- State machine: `State` enum tracks lifecycle (new, translated, stale, needsReview, needsWork, translateLater, dontTranslate)
- Supports hierarchical organization (parent/child) for plural/device variations
- Includes `isModified`, `needsReview`, `translateLater`, `needsWork` flags
- Provides `translationStatus` comparison (exact/similar/different) via reverse translation

**XCStrings** (`Model/XCStrings.swift`)
- Codable wrapper for the `.xcstrings` JSON structure
- Properties: `version`, `sourceLanguage`, `strings` array
- Custom encode/decode to map `[String: XCString]` to flat `XCString` array with `key` property
- Preserves the exact JSON format when roundtripping

### Translation System

**Translator Protocol** (`Helper/Protocols/Translator.swift`)
- Abstraction for translation services with three methods:
  - `translate()`: translates text between languages
  - `detect()`: identifies source language
  - `languages()`: retrieves supported languages

**Implementations:**
- `GoogleTranslator` → `GoogleAPI`
- `DeepLTranslator` → `DeepLAPI`
- `BaiduTranslator` → `BaiduAPI`
- `LLMTranslator` → `LLMAPI`

**TranslatorFactory** (`Model/TranslatorFactory.swift`)
- Factory pattern returning translator based on `UserDefaults.standard.translationService`
- Single responsibility: abstract away translator selection

**NetworkManager** (`Helper/NetworkManager.swift`)
- Generic HTTP client for all API requests
- Builds URLs from `API` protocol implementations
- Handles JSON serialization and error responses

**API Protocol** (`Helper/Protocols/API.swift`)
- Defines HTTP request structure: scheme, baseURL, path, parameters, method, body, headers
- `TranslateAPI` protocol extends this for translation-specific operations

### Views

**ContentView** (`ContentView.swift`)
- Main editor interface with table-based layout
- Three columns: Key, Default Localization (source), Translation (current language)
- Integrates filtering (by state, search), sorting, and language selection
- Modal editing for translation text
- Focus management between search, table, and edit fields

**WelcomeView** (`WelcomeView.swift`)
- Initial screen showing recent files and quick actions
- Appears when no file is open

**SettingsView** (`SettingsView.swift`)
- Configuration for API keys (Google, DeepL, Baidu, LLM)
- Translation service selection

**ItemStateView** (`ItemStateView.swift`)
- Visual badge/indicator for LocalizeItem state

## Key Design Patterns

1. **Factory Pattern**: `TranslatorFactory` abstracts translator creation
2. **Protocol-Based Design**: `Translator`, `TranslateAPI`, `API` enable extensibility
3. **Observable Pattern**: `@Observable` AppModel for reactive UI updates
4. **State Machine**: LocalizeItem.State enum defines item lifecycle
5. **Protocol Hierarchy**: API/TranslateAPI split concerns between HTTP and translation-specific logic

## File Structure

```
XCStringsEditor/
├── Model/
│   ├── AppModel.swift (central state)
│   ├── LocalizeItem.swift (core data structure)
│   ├── XCStrings.swift (JSON serialization)
│   ├── Language.swift (language definitions)
│   ├── TranslatorFactory.swift (translator selection)
│   └── ... (error types, file settings, detection)
├── Translators/
│   ├── GoogleTranslator.swift
│   ├── DeepLTranslator.swift
│   ├── BaiduTranslator.swift
│   └── LLMTranslator.swift
├── APIs/
│   ├── GoogleAPI.swift
│   ├── DeepLAPI.swift
│   ├── BaiduAPI.swift
│   └── LLMAPI.swift
├── Helper/
│   ├── NetworkManager.swift (HTTP client)
│   └── Protocols/
│       ├── API.swift (HTTP structure + TranslateAPI)
│       └── Translator.swift (translation interface)
├── ContentView.swift (main editor)
├── WelcomeView.swift (file selection)
├── SettingsView.swift (configuration)
└── ... (supporting files, assets, extensions)
```

## Adding a New Translation Service

1. Create `NewServiceTranslator.swift` implementing `Translator` protocol
2. Create `NewServiceAPI.swift` implementing `TranslateAPI` protocol (and individual API conformances)
3. Update `TranslatorFactory.switch` case to instantiate `NewServiceTranslator`
4. Add API key input to `SettingsView`
5. Store credentials in `UserDefaults` via extension (see `UserDefaults+Keys`)

## Important Notes

- **Plural/Device Variations**: The UI supports displaying plural and device variations but doesn't yet support adding/removing them—these must be managed in Xcode first.
- **File Format**: `.xcstrings` files are JSON. AppModel roundtrips them preserving format.
- **State Persistence**: Language preference, recent files, API keys, and filter/visibility settings are persisted via `UserDefaults`.
- **No Tests**: Manual testing in the app is the verification method.
- **OSLog Integration**: Logging via `Logger` for debugging (check categories in AppModel, ContentView).
