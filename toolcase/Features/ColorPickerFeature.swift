//
//  ColorPickerFeature.swift
//  Toolcase
//
//  Copyright © 2025 Neeraj Kumar. All rights reserved.
//

import SwiftUI
import AppKit

// MARK: - Color Picker Feature
// Shortcut: ⌃⌥P — Pick any color from the screen and copy its hex code

struct ColorPickerMenuItem: View {
    @State private var copiedHex: String? = nil
    @State private var copiedColor: Color? = nil
    @State private var showCopiedAnimation: Bool = false
    
    var body: some View {
        MenuItemView(
            title: "Color Picker",
            icon: "eyedropper",
            iconColor: .blue,
            shortcutText: "⌃⌥P",
            action: pickColor
        ) {
            if let hex = copiedHex, let color = copiedColor {
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(color)
                        .frame(width: 16, height: 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                        )
                    
                    Text(hex)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        copyToClipboard(hex: hex)
                    }) {
                        Image(systemName: showCopiedAnimation ? "checkmark.circle.fill" : "doc.on.doc")
                            .font(.system(size: 11))
                            .foregroundColor(showCopiedAnimation ? .green : .secondary.opacity(0.6))
                            .scaleEffect(showCopiedAnimation ? 1.15 : 1.0)
                    }
                    .buttonStyle(.plain)
                    .help("Copy Hex")
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showCopiedAnimation)
            }
        }
    }
    
    private func copyToClipboard(hex: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(hex, forType: .string)
        
        if let color = copiedColor {
            OverlayManager.shared.showColorToast(hex: hex, color: color)
        }
        
        withAnimation {
            showCopiedAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showCopiedAnimation = false
            }
        }
    }
    
    private func pickColor() {
        let sampler = NSColorSampler()
        sampler.show { selectedColor in
            if let nsColor = selectedColor, let hex = nsColor.toHex() {
                DispatchQueue.main.async {
                    self.copiedHex = hex
                    self.copiedColor = Color(nsColor: nsColor)
                    self.copyToClipboard(hex: hex)
                }
            }
        }
    }
}
