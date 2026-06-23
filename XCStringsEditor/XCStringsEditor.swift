import SwiftUI

// MARK: - Module Public API

/// Convenient alias for XCStringsEditorView
public typealias Editor = XCStringsEditorView

// MARK: - Main Public Components

// XCStringsEditorView is defined in XCStringsEditorView.swift and exported here
// EditorConfiguration is defined in Model/EditorConfiguration.swift and exported here
// TranslationService is defined in Model/EditorConfiguration.swift and exported here

// MARK: - Public Data Models

// LocalizeItem is defined in Model/LocalizeItem.swift and exported here
// XCStrings is defined in Model/XCStrings.swift and exported here
// Language is defined in Model/Language.swift and exported here

// MARK: - Protocol for Advanced Use

// Translator is defined in Helper/Protocols/Translator.swift and exported here

// MARK: - Window Management

// WindowDelegate is defined in WindowDelegate.swift and exported here

// This module re-exports the following public types for convenient imports:
// - XCStringsEditorView: Main UI component for embedding in host apps
// - EditorConfiguration: Configuration struct for editor settings
// - TranslationService: Enum selecting translation service
// - LocalizeItem: Model representing a localizable string
// - XCStrings: Root model for .xcstrings file format
// - Language: Enum of supported languages
// - Translator: Protocol for custom translation service implementations
// - WindowDelegate: NSWindowDelegate for macOS window management
