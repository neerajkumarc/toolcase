//
//  ClipboardHistoryFeature.swift
//  Toolcase
//
//  Copyright © 2025 Neeraj Kumar. All rights reserved.
//

import SwiftUI
import Combine
import AppKit

// MARK: - Clipboard History Feature
// Shortcut: ⌃⌥V — View and re-copy from your clipboard history

struct ClipboardHistoryMenuItem: View {
    @ObservedObject var manager = ClipboardManager.shared
    
    var body: some View {
        MenuItemView(
            title: "Clipboard History",
            icon: "list.clipboard",
            iconColor: .orange,
            shortcutText: "⌃⌥V",
            action: showHistory
        ) {
            if manager.history.count > 0 {
                Text("\(manager.history.count)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(
                        Circle()
                            .fill(Color.orange.opacity(0.8))
                    )
            }
        }
    }
    
    private func showHistory() {
        OverlayManager.shared.showClipboardHistory()
    }
}
