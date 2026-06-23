//
//  SourceModel.swift
//  XCStringsEditor
//
//  Created by 王培屹 on 13/9/24.
//

import Foundation

struct InputModel {
    let text: String
    let source: String
    let target: String
    let format: String
    let model: String

    init(text: String, source: String, target: String, format: String = "text", model: String = "base") {
        self.text = text
        self.source = source
        self.target = target
        self.format = format
        self.model = model
    }
}
