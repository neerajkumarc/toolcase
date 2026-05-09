//
//  ClipboardHistoryView.swift
//  Toolcase
//
//  Copyright © 2025 Neeraj Kumar. All rights reserved.
//

import SwiftUI
import Combine

/// The floating clipboard history panel showing recent clipboard entries.
struct ClipboardHistoryView: View {
    @ObservedObject var manager = ClipboardManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "list.clipboard")
                Text("Clipboard History")
                Spacer()
                if !manager.history.isEmpty {
                    Text("\(manager.history.count) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .font(.headline)
            .padding()
            
            Divider()
            
            if manager.history.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "clipboard")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary.opacity(0.4))
                    Text("Your clipboard history is empty.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(manager.history) { item in
                            ClipboardItemRow(item: item)
                            Divider().padding(.leading, 16)
                        }
                    }
                }
            }
        }
        .frame(width: 400, height: 380)
        .background(VisualEffectView().ignoresSafeArea())
    }
}

// MARK: - ClipboardItemRow

/// A single row in the clipboard history — displays text or image preview.
struct ClipboardItemRow: View {
    let item: ClipboardItem
    @State private var isHovered = false
    
    var body: some View {
        Button(action: copyItem) {
            HStack(spacing: 12) {
                // Type icon
                Group {
                    switch item {
                    case .text:
                        Image(systemName: "doc.text")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary.opacity(0.5))
                            .frame(width: 16)
                    case .image:
                        Image(systemName: "photo")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary.opacity(0.5))
                            .frame(width: 16)
                    }
                }
                
                // Content
                switch item {
                case .text(let str):
                    Text(str)
                        .lineLimit(2)
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                case .image(let data, let w, let h):
                    HStack(spacing: 10) {
                        if let nsImage = NSImage(data: data) {
                            Image(nsImage: nsImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 48, height: 48)
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Image")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.primary)
                            Text("\(w) × \(h) px")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isHovered ? Color.accentColor.opacity(0.1) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
    
    private func copyItem() {
        NSPasteboard.general.clearContents()
        
        switch item {
        case .text(let str):
            NSPasteboard.general.setString(str, forType: .string)
        case .image(let data, _, _):
            if let nsImage = NSImage(data: data),
               let tiffData = nsImage.tiffRepresentation {
                NSPasteboard.general.setData(tiffData, forType: .tiff)
            }
        }
        
        OverlayManager.shared.hideClipboardHistory()
        OverlayManager.shared.showToast(icon: "checkmark.circle.fill", iconColor: .green)
    }
}
