//
//  ToolcaseApp.swift
//  Toolcase
//
//  Copyright © 2025 Neeraj Kumar. All rights reserved.
//

import SwiftUI

@main
struct ToolcaseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("Toolcase", systemImage: "briefcase.fill") {
            ContentView()
        }
        .menuBarExtraStyle(.window)
    }
}
