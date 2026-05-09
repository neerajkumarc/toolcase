//
//  MicToggleFeature.swift
//  Toolcase
//
//  Copyright © 2025 Neeraj Kumar. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - Microphone Toggle Feature
// Shortcut: ⌃⌥M — Mute/unmute your system microphone at the hardware level

struct MicToggleMenuItem: View {
    @ObservedObject var audio = AudioManager.shared
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: audio.isMuted ? "mic.slash.fill" : "mic.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill((audio.isMuted ? Color.red : Color.green).gradient)
                )
            
            // Label + shortcut
            VStack(alignment: .leading, spacing: 1) {
                Text("Microphone")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                
                Text("⌃⌥M")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary.opacity(0.7))
            }
            
            Spacer()
            
            // Native Toggle Switch
            Toggle("", isOn: Binding(
                get: { !audio.isMuted },
                set: { newValue in
                    audio.setMicMuted(!newValue)
                    if newValue {
                        OverlayManager.shared.showToast(icon: "mic.fill", iconColor: .green)
                    } else {
                        OverlayManager.shared.showToast(icon: "mic.slash.fill", iconColor: .red)
                    }
                }
            ))
            .toggleStyle(.switch)
            .labelsHidden()
            .controlSize(.small)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.clear)
        )
        .contentShape(Rectangle())
    }
}
