//
//  FeatureRegistry.swift
//  Toolcase
//
//  Copyright © 2025 Neeraj Kumar. All rights reserved.
//

import SwiftUI

// MARK: - Feature Entry

/// Represents a registered feature that appears in the "Standard Tools" section.
struct FeatureEntry: Identifiable {
    let id: String
    let title: String
    let keywords: [String]
    let view: AnyView
}

// MARK: - Feature Registry

/// Central registry of all built-in tools.
/// To add a new feature:
/// 1. Create a new `.swift` file in `Features/`
/// 2. Add an entry to `FeatureRegistry.all` below
struct FeatureRegistry {
    static let all: [FeatureEntry] = [
        FeatureEntry(
            id: "color-picker",
            title: "Pick Color from Screen",
            keywords: ["eyedropper", "hex", "color", "picker", "screen"],
            view: AnyView(ColorPickerMenuItem())
        ),
        FeatureEntry(
            id: "clipboard-history",
            title: "Clipboard History",
            keywords: ["clipboard", "paste", "copy", "history"],
            view: AnyView(ClipboardHistoryMenuItem())
        ),
        FeatureEntry(
            id: "mic-toggle",
            title: "Microphone Toggle",
            keywords: ["mic", "mute", "unmute", "microphone", "audio"],
            view: AnyView(MicToggleMenuItem())
        ),
    ]
    
    /// Filter features by a search query matching title or keywords.
    static func search(_ query: String) -> [FeatureEntry] {
        if query.isEmpty { return all }
        let q = query.lowercased()
        return all.filter { entry in
            entry.title.lowercased().contains(q) ||
            entry.keywords.contains(where: { $0.contains(q) })
        }
    }
}
