//
//  LaunchAtStartupFeature.swift
//  Toolcase
//
//  Copyright © 2025 Neeraj Kumar. All rights reserved.
//

import SwiftUI
import ServiceManagement

// MARK: - Launch at Startup Feature
// Toggle whether Toolcase automatically starts when you log in

struct LaunchAtStartupMenuItem: View {
    @State private var launchAtStartup: Bool = {
        return SMAppService.mainApp.status == .enabled
    }()
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: "sunrise.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(Color.indigo.gradient)
                )
            
            // Label
            Text("Launch at Startup")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Native Toggle Switch
            Toggle("", isOn: $launchAtStartup)
                .toggleStyle(.switch)
                .labelsHidden()
                .controlSize(.small)
                .onChange(of: launchAtStartup) { oldValue, newValue in
                    toggleLaunchAtStartup(enabled: newValue)
                }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
    
    private func toggleLaunchAtStartup(enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("[Toolcase] Failed to toggle launch at startup: \(error)")
            launchAtStartup = !enabled
        }
    }
}
