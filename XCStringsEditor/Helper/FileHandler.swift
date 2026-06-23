import Foundation

/// Handles file I/O for the standalone app
internal class FileHandler {
    func loadXCStrings(from url: URL) async throws -> XCStrings {
        let data = try Data(contentsOf: url)
        let xcstrings = try JSONDecoder().decode(XCStrings.self, from: data)
        return xcstrings
    }

    func saveXCStrings(_ xcstrings: XCStrings, to url: URL) async throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(xcstrings)
        try data.write(to: url, options: [.atomic])
    }
}
