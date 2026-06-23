// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "XCStringsEditor",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "XCStringsEditor",
            targets: ["XCStringsEditor"]
        )
    ],
    targets: [
        .target(
            name: "XCStringsEditor",
            path: "XCStringsEditor",
            publicHeadersPath: "."
        )
    ]
)
