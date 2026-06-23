import SwiftUI

/// A SwiftUI view for editing `.xcstrings` localization files.
///
/// `XCStringsEditorView` provides a complete UI for managing translations across multiple languages.
/// It's designed to be embedded in host applications that need localization editing capabilities.
///
/// ## Overview
///
/// The editor handles:
/// - Multi-language translation editing
/// - Filtering items by state (new, translated, stale, etc.)
/// - Automatic translation via configurable services (Google, DeepL, Baidu, LLM)
/// - Language selection and switching
/// - Real-time state updates as the user edits
///
/// ## Integration Pattern
///
/// The host application owns all file I/O and data persistence. The editor only manages
/// in-memory state. When the user makes changes, they're reflected in the `data` parameter
/// that was passed in.
///
/// ```swift
/// @State var xcstringsData: XCStrings
/// @State var config: EditorConfiguration
///
/// var body: some View {
///     XCStringsEditorView(data: xcstringsData, configuration: config)
/// }
/// ```
///
/// ## State Management
///
/// The editor uses an internal `@Observable AppModel` to manage editing state. Changes
/// are made directly to the `data` object passed to the initializer.
///
/// ## Environment Requirements
///
/// The editor requires `WindowDelegate` in the environment for proper window management
/// on macOS. The host app must provide this:
///
/// ```swift
/// @State var windowDelegate = WindowDelegate()
/// var body: some View {
///     XCStringsEditorView(data: data, configuration: config)
///         .environment(\.windowDelegate, windowDelegate)
/// }
/// ```
///
/// ## Parameters
///
/// - `data`: The `XCStrings` object to edit. Changes are made in-memory.
/// - `configuration`: Editor configuration including language, translation services, and UI preferences.
@MainActor
public struct XCStringsEditorView: View {
    @State private var appModel: AppModel

    /// Initializes the editor with XCStrings data and configuration.
    ///
    /// - Parameters:
    ///   - data: The `XCStrings` data to edit. Will be mutated as user makes changes.
    ///   - configuration: Editor configuration with language, translation services, and preferences.
    public init(data: XCStrings, configuration: EditorConfiguration) {
        _appModel = State(initialValue: AppModel(data: data, configuration: configuration))
    }

    public var body: some View {
        ContentView()
            .environment(appModel)
    }
}

#if DEBUG
#Preview {
    let sampleXCStrings = XCStrings(
        version: "3.0",
        sourceLanguage: .english,
        strings: [
            XCString(
                key: "hello",
                comment: "Greeting",
                shouldTranslate: true,
                extractionState: .manual,
                localizations: [
                    .english: XCString.Localization(
                        stringUnit: XCString.Localization.StringUnit(state: .translated, value: "Hello")
                    ),
                    Language(code: "fr")!: XCString.Localization(
                        stringUnit: XCString.Localization.StringUnit(state: .translated, value: "Bonjour")
                    )
                ]
            )
        ]
    )

    let config = EditorConfiguration(
        baseLanguage: .english,
        currentLanguage: Language(code: "fr") ?? .english,
        translationService: .google,
        googleAPIKey: "test-key"
    )

    XCStringsEditorView(data: sampleXCStrings, configuration: config)
}
#endif
