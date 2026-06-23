//
//  XCStrings.swift
//  XCStringEditor
//
//  Created by JungHoon Noh on 1/24/24.
//

import Foundation

/// The root data structure representing an `.xcstrings` localization file.
///
/// `XCStrings` encapsulates a complete localization file in the `.xcstrings` format
/// introduced in Xcode 15. It contains metadata about the file and a collection of
/// translatable strings with their localizations.
///
/// ## Structure
///
/// ```json
/// {
///   "version": "3.0",
///   "sourceLanguage": "en",
///   "strings": {
///     "greeting": { /* XCString */ },
///     "farewell": { /* XCString */ }
///   }
/// }
/// ```
///
/// ## Serialization
///
/// `XCStrings` conforms to `Codable`, enabling round-trip serialization to/from JSON.
/// The structure is preserved during encoding/decoding to maintain compatibility with
/// Xcode.
///
/// ## Loading from File
///
/// ```swift
/// let data = try Data(contentsOf: fileURL)
/// let xcstrings = try JSONDecoder().decode(XCStrings.self, from: data)
/// ```
///
/// ## Saving to File
///
/// ```swift
/// let encoder = JSONEncoder()
/// encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
/// let data = try encoder.encode(xcstrings)
/// try data.write(to: fileURL, options: .atomic)
/// ```
///
public struct XCStrings: Codable, Equatable {
    /// The format version of the `.xcstrings` file.
    ///
    /// Currently "3.0" for Xcode 15+.
    public var version: String

    /// The source/base language of all strings in this file.
    ///
    /// All string values should be written in this language.
    public var sourceLanguage: Language

    /// The collection of translatable strings.
    ///
    /// Each `XCString` represents a single translatable unit with its source text
    /// and localizations for different languages.
    public var strings: [XCString]

    private enum CodingKeys: CodingKey {
        case sourceLanguage, version, strings
    }

    /// Creates a new XCStrings instance.
    ///
    /// - Parameters:
    ///   - version: The format version (typically "3.0").
    ///   - sourceLanguage: The base language of all strings.
    ///   - strings: Array of translatable string entries.
    public init(version: String, sourceLanguage: Language, strings: [XCString]) {
        self.version = version
        self.sourceLanguage = sourceLanguage
        self.strings = strings
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        version = try values.decode(String.self, forKey: .version)
        let sourceLanguageCode = try values.decode(String.self, forKey: .sourceLanguage)
        sourceLanguage = Language(code: sourceLanguageCode)!

        let stringDict = try values.decode([String: XCString].self, forKey: .strings)
        var strings = [XCString]()
        for (key, string) in stringDict {
            var string = string
            string.key = key
            strings.append(string)
        }
        self.strings = strings
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(version, forKey: .version)
        try container.encode(sourceLanguage.code, forKey: .sourceLanguage)
     
        var s = [String: XCString]()
        for string in strings {
            s[string.key!] = string
        }
        try container.encode(s, forKey: .strings)
    }
    
    func printStrings() {
        for string in strings {
            print(string.key ?? "-", string.comment ?? "-")

            for (key, l) in string.localizations {
                print(" ", key)

                if let stringUnit = l.stringUnit {
                    print("   ", stringUnit.value)

                } else if let pluralVariation = l.pluralVariation {
                    for (key, localization) in pluralVariation {
                        print("   plural", key, localization.stringUnit!.value)
                    }
                } else if let variation = l.deviceVariation {
                    for (key, localization) in variation {
                        print("   device", key)
                        if let stringUnit = localization.stringUnit {
                            print("     ", stringUnit.value)
                        } else if let pluralVariation = localization.pluralVariation {
                            for (key, localization) in pluralVariation {
                                print("       plural", key, localization.stringUnit!.value)
                            }
                        }
                    }
                }
            }
        }
    }
}

public struct XCString: Codable, Equatable {
    public enum ExtractionState: String {
        case none
        case stale
        case manual
        case extractedWithValue = "extracted_with_value"
    }
    public enum VariationKind: CodingKey {
        case plural
        case device
    }

    public enum DeviceType: String, Hashable {
        case iphone
        case ipod
        case ipad
        case applewatch
        case appletv
        case applevision
        case mac
        case other
        
        var sortNum: Int {
            switch self {
            case .iphone: return 0
            case .ipod: return 1
            case .ipad: return 2
            case .applewatch: return 3
            case .appletv: return 4
            case .applevision: return 5
            case .mac: return 6
            case .other: return 7
            }
        }
        
        var localizedName: String {
            switch self {
            case .iphone:
                return String(localized: "iPhone")
            case .ipod:
                return String(localized: "iPod")
            case .ipad:
                return String(localized: "iPad")
            case .applewatch:
                return String(localized: "Apple Watch")
            case .appletv:
                return String(localized: "Apple TV")
            case .applevision:
                return String(localized: "Apple Vision")
            case .mac:
                return String(localized: "Mac")
            case .other:
                return String(localized: "Other")
            }
        }
    }

    public enum PluralType: String, Hashable {
        case zero
        case one
        case two
        case few
        case many
        case other
        
        var sortNum: Int {
            switch self {
            case .zero: return 0
            case .one: return 1
            case .two: return 2
            case .few: return 3
            case .many: return 4
            case .other: return 5
            }
        }
        
        var localizedName: String {
            switch self {
            case .zero:
                return String(localized: "Zero")
            case .one:
                return String(localized: "One")
            case .two:
                return String(localized: "Two")
            case .few:
                return String(localized: "Few")
            case .many:
                return String(localized: "Many")
            case .other:
                return String(localized: "Other")
            }
        }
    }

    public typealias PluralVariation = [PluralType: Localization]
    public typealias DeviceVariation = [DeviceType: Localization]

    // Localization
    public struct Localization: Codable, Equatable {

        // StringUnit
        public struct StringUnit: Codable, Equatable {
            public enum State: String {
                case new
                case translated
                case needsReview = "needs_review"
            }

            public var state: State
            public var value: String

            private enum CodingKeys: CodingKey {
                case state, value
            }

            public init(state: State, value: String) {
                self.state = state
                self.value = value
            }

            public init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)

                let stateValue = try values.decode(String.self, forKey: .state)
                state = State(rawValue: stateValue) ?? .new
                value = try values.decode(String.self, forKey: .value)
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                try container.encode(value, forKey: .value)
                try container.encode(state.rawValue, forKey: .state)
            }
            
            mutating func update(state: State, value: String) {
                
            }
        } // StringUnit

        public var stringUnit: StringUnit?
        public var pluralVariation: [PluralType: Localization]?
        public var deviceVariation: [DeviceType: Localization]?

        public init(stringUnit: StringUnit? = nil, pluralVariation: [PluralType: Localization]? = nil, deviceVariation: [DeviceType: Localization]? = nil) {
            self.stringUnit = stringUnit
            self.pluralVariation = pluralVariation
            self.deviceVariation = deviceVariation
        }

        private enum CodingKeys: CodingKey {
            case stringUnit, variations
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            stringUnit = try values.decodeIfPresent(StringUnit.self, forKey: .stringUnit)

            if stringUnit == nil {
                let variationContainer = try values.nestedContainer(keyedBy: VariationKind.self, forKey: .variations)

                if let pluralVariationDict = try variationContainer.decodeIfPresent([String: Localization].self, forKey: .plural) {
                    var pluralVariations = [PluralType: Localization]()
                    for (key, localization) in pluralVariationDict {
                        pluralVariations[PluralType(rawValue: key)!] = localization
                    }
                    self.pluralVariation = pluralVariations
                }

                if let deviceVariationDict = try variationContainer.decodeIfPresent([String: Localization].self, forKey: .device) {
                    var deviceVariations = [DeviceType: Localization]()
                    for (key, localization) in deviceVariationDict {
                        deviceVariations[DeviceType(rawValue: key)!] = localization
                    }
                    self.deviceVariation = deviceVariations
                }
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            if let stringUnit {
                try container.encode(stringUnit, forKey: .stringUnit)
                
            } else {
                if let pluralVariation {
                    var variations = [String: Localization]()
                    for (key, localization) in pluralVariation {
                        variations[key.rawValue] = localization
                    }
                    try container.encode(["plural": variations], forKey: .variations)

                } else if let deviceVariation {
                    var variations = [String: Localization]()
                    for (key, localization) in deviceVariation {
                        variations[key.rawValue] = localization
                    }
                    try container.encode(["device": variations], forKey: .variations)
                }
            }
        }
    } // Localization


    public var comment: String?
    public var key: String?
    public var localizations: [Language: Localization]
    public var extractionState: ExtractionState = .none
    public var shouldTranslate: Bool = true
    
    private enum CodingKeys: CodingKey {
        case comment, key, localizations, extractionState, shouldTranslate
    }

    public init(key: String? = nil, comment: String? = nil, shouldTranslate: Bool = true, extractionState: ExtractionState = .none, localizations: [Language: Localization] = [:]) {
        self.key = key
        self.comment = comment
        self.shouldTranslate = shouldTranslate
        self.extractionState = extractionState
        self.localizations = localizations
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let comment {
            try container.encode(comment, forKey: .comment)
        }
        if extractionState != .none {
            try container.encode(extractionState.rawValue, forKey: .extractionState)
        }
        
        var l = [String: Localization]()
        for (key, localization) in localizations {
            l[key.rawValue] = localization
        }
        if l.isEmpty == false {
            try container.encode(l, forKey: .localizations)
        }
        if shouldTranslate == false {
            try container.encode(shouldTranslate, forKey: .shouldTranslate)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        key = nil
        comment = try values.decodeIfPresent(String.self, forKey: .comment)
        if let stateValue = try values.decodeIfPresent(String.self, forKey: .extractionState), stateValue.isEmpty == false {
            extractionState = ExtractionState(rawValue: stateValue)!
        }
        
        if let localizationsDict = try values.decodeIfPresent([String: Localization].self, forKey: .localizations) {
            var localizations = [Language: Localization]()
            for (key, localization) in localizationsDict {
                if let key = Language(code: key) {
                    localizations[key] = localization
                }
            }
            
            self.localizations = localizations
        } else {
            self.localizations = [:]
        }
        
        shouldTranslate = try values.decodeIfPresent(Bool.self, forKey: .shouldTranslate) ?? true
    }
}
