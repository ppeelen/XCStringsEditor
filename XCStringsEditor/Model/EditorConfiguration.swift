import Foundation

/// Configuration and settings for the XCStringsEditor.
///
/// `EditorConfiguration` encapsulates all settings needed by the editor, replacing direct
/// `UserDefaults` access. This enables clean dependency injection and makes the editor
/// suitable for embedding in various host applications with different configuration needs.
///
/// ## Overview
///
/// Configuration includes:
/// - Language selection (base and current editing language)
/// - Translation service selection and API credentials
/// - UI filtering preferences (which item states to hide)
///
/// ## Creating a Configuration
///
/// ```swift
/// let config = EditorConfiguration(
///     baseLanguage: .english,
///     currentLanguage: .french,
///     translationService: .google,
///     googleAPIKey: loadFromSecureStorage("google_api_key")
/// )
/// ```
///
/// ## API Key Management
///
/// **Important:** Never hardcode API keys in your source code. Instead:
/// 1. Load from secure storage (Keychain, environment variables)
/// 2. Load from configuration files (gitignored)
/// 3. Prompt user to enter at runtime
///
/// If an API key is not provided, that translation service will be disabled in the UI.
///
/// ## UI Preferences
///
/// The configuration allows hiding certain item states from the editor view:
/// - `translateLaterItemsHidden`: Hide items marked "Translate Later"
/// - `staleItemsHidden`: Hide stale translations
/// - `dontTranslateItemsHidden`: Hide items marked "Don't Translate"
///
public struct EditorConfiguration {
    /// The source/base language of the strings file.
    ///
    /// This is the language in which the original strings are written. All translations
    /// are made from this language.
    public let baseLanguage: Language

    /// The language currently being edited.
    ///
    /// Users can switch languages in the editor, updating this value. You may want to
    /// persist this to UserDefaults so the user returns to their preferred language.
    public var currentLanguage: Language

    /// The translation service to use for automatic translation.
    ///
    /// Options: `.google`, `.deepL`, `.baidu`, `.llm`
    ///
    /// Make sure the corresponding API key is provided in configuration.
    public let translationService: TranslationService

    /// Google Translate API key.
    ///
    /// Required if `translationService == .google`. Leave `nil` if not using Google Translate.
    public let googleAPIKey: String?

    /// DeepL API key.
    ///
    /// Required if `translationService == .deepL`. Leave `nil` if not using DeepL.
    public let deeplAPIKey: String?

    /// Baidu API credentials (App ID and Secret Key combined).
    ///
    /// Required if `translationService == .baidu`. Leave `nil` if not using Baidu.
    public let baiduAPIKey: String?

    /// LLM API key (for custom language model services).
    ///
    /// Required if `translationService == .llm`. Leave `nil` if not using LLM services.
    public let llmAPIKey: String?

    /// Hide items marked as "Translate Later" from the editor view.
    ///
    /// Default: `false` (show all items)
    public var translateLaterItemsHidden: Bool = false

    /// Hide stale translations from the editor view.
    ///
    /// A translation is stale when the source text has changed but the translation hasn't been updated.
    ///
    /// Default: `false` (show all items)
    public var staleItemsHidden: Bool = false

    /// Hide items marked as "Don't Translate" from the editor view.
    ///
    /// Default: `false` (show all items)
    public var dontTranslateItemsHidden: Bool = false

    /// Creates a new editor configuration.
    ///
    /// - Parameters:
    ///   - baseLanguage: The source language of the strings file.
    ///   - currentLanguage: The language to start editing with.
    ///   - translationService: The translation service to use.
    ///   - googleAPIKey: Optional Google Translate API key.
    ///   - deeplAPIKey: Optional DeepL API key.
    ///   - baiduAPIKey: Optional Baidu API key.
    ///   - llmAPIKey: Optional LLM API key.
    ///   - translateLaterItemsHidden: Hide "Translate Later" items.
    ///   - staleItemsHidden: Hide stale translations.
    ///   - dontTranslateItemsHidden: Hide "Don't Translate" items.
    public init(
        baseLanguage: Language,
        currentLanguage: Language,
        translationService: TranslationService,
        googleAPIKey: String? = nil,
        deeplAPIKey: String? = nil,
        baiduAPIKey: String? = nil,
        llmAPIKey: String? = nil,
        translateLaterItemsHidden: Bool = false,
        staleItemsHidden: Bool = false,
        dontTranslateItemsHidden: Bool = false
    ) {
        self.baseLanguage = baseLanguage
        self.currentLanguage = currentLanguage
        self.translationService = translationService
        self.googleAPIKey = googleAPIKey
        self.deeplAPIKey = deeplAPIKey
        self.baiduAPIKey = baiduAPIKey
        self.llmAPIKey = llmAPIKey
        self.translateLaterItemsHidden = translateLaterItemsHidden
        self.staleItemsHidden = staleItemsHidden
        self.dontTranslateItemsHidden = dontTranslateItemsHidden
    }
}

/// Options for automatic translation services.
///
/// The editor supports multiple translation service providers. Each requires specific API credentials
/// which should be provided in `EditorConfiguration`.
///
/// ## Supported Services
///
/// - `google`: Google Translate API
/// - `deepL`: DeepL API
/// - `baidu`: Baidu Translate API
/// - `llm`: Custom language model services
///
public enum TranslationService: String, Codable, CaseIterable {
    /// Google Translate API
    case google
    /// DeepL translation service
    case deepL
    /// Baidu Translate API
    case baidu
    /// Custom language model service
    case llm

    public var name: String {
        switch self {
        case .google: return "Google Translate"
        case .deepL: return "DeepL"
        case .baidu: return "Baidu"
        case .llm: return "LLM"
        }
    }
}
