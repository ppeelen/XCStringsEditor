//
//  WindowDelegate.swift
//  XCStringsEditor
//
//  Created by JungHoon Noh on 2/8/24.
//

import AppKit
import SwiftUI

/// Handles macOS window lifecycle events for the XCStringsEditor.
///
/// `WindowDelegate` implements `NSWindowDelegate` to manage window closure behavior,
/// particularly to warn users when they attempt to close with unsaved changes.
///
/// ## Usage
///
/// Create an instance in your app and place it in the SwiftUI environment:
///
/// ```swift
/// @State var windowDelegate = WindowDelegate()
///
/// var body: some Scene {
///     WindowGroup {
///         XCStringsEditorView(data: data, configuration: config)
///             .environment(\.windowDelegate, windowDelegate)
///     }
/// }
/// ```
///
/// ## Customizing Close Behavior
///
/// Set the `allowClose` closure to customize whether the window can be closed:
///
/// ```swift
/// windowDelegate.allowClose = {
///     // Return false to prevent closing (e.g., when there are unsaved changes)
///     return !hasUnsavedChanges
/// }
/// ```
///
/// When `allowClose()` returns `false`, the window will not close and an alert
/// can be displayed to the user.
///
@Observable
public class WindowDelegate: NSObject, NSWindowDelegate {
    /// Closure that determines whether the window is allowed to close.
    ///
    /// Return `true` to allow closing, `false` to prevent it.
    /// Used to prevent closing with unsaved changes.
    public var allowClose: () -> Bool = {
        true
    }

    /// Called when the user attempts to close the window.
    ///
    /// Checks the `allowClose` closure to determine if the window should be closed.
    public func windowShouldClose(_ sender: NSWindow) -> Bool {
        return allowClose()
    }

    /// Creates a new window delegate.
    public override init() {
        super.init()
    }
}

// EnvironmentKey for WindowDelegate
public struct WindowDelegateKey: EnvironmentKey {
    public static let defaultValue: WindowDelegate = WindowDelegate()
}

extension EnvironmentValues {
    public var windowDelegate: WindowDelegate {
        get { self[WindowDelegateKey.self] }
        set { self[WindowDelegateKey.self] = newValue }
    }
}
