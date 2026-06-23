//
//  TranslatorFactory.swift
//  XCStringsEditor
//
//  Created by 王培屹 on 13/9/24.
//

import Foundation
final class TranslatorFactory {
    static func translator(for configuration: EditorConfiguration) -> any Translator {
        switch configuration.translationService {
        case .google:
            return GoogleTranslator()
        case .deepL:
            return DeepLTranslator()
        case .baidu:
            return BaiduTranslator()
        case .llm:
            return LLMTranslator()
        }
    }
}
