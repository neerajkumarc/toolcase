//
//  AppDelegate.swift
//  Toolcase
//
//  Copyright © 2025 Neeraj Kumar. All rights reserved.
//

import SwiftUI

/// Handles app lifecycle events — hides from Dock and starts background services.
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide the app from the Dock and Application Switcher
        NSApplication.shared.setActivationPolicy(.accessory)
        
        // Start the global background managers
        GlobalHotkeyManager.shared.start()
        ClipboardManager.shared.start()
        
        // Register hotkeys for user-added dynamic tools
        DynamicToolManager.shared.registerAllHotkeys()
    }
}
