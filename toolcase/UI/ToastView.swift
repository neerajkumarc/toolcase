//
//  ToastView.swift
//  Toolcase
//
//  Copyright © 2025 Neeraj Kumar. All rights reserved.
//

import SwiftUI

/// A floating icon-only toast notification displayed at the bottom of the screen.
struct ToastView: View {
    let icon: String
    let iconColor: Color
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 32, weight: .medium))
            .foregroundColor(iconColor)
            .frame(width: 64, height: 64)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.black.opacity(0.85))
                    .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 4)
            )
    }
}

/// A floating toast that displays a color swatch alongside its hex code.
struct ColorToastView: View {
    let hex: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(color)
                .frame(width: 36, height: 36)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            
            Text(hex)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .fixedSize()
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.black.opacity(0.85))
                .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 4)
        )
    }
}
