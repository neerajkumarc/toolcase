//
//  ContentView.swift
//  Toolcase
//
//  Copyright © 2025 Neeraj Kumar. All rights reserved.
//

import SwiftUI
import Combine

/// The main menu bar panel — displays standard tools, user-created tools, and settings.
struct ContentView: View {
    @State private var searchText = ""
    @ObservedObject private var dynamicManager = DynamicToolManager.shared
    
    private var filteredFeatures: [FeatureEntry] {
        FeatureRegistry.search(searchText)
    }
    
    private var filteredDynamicTools: [DynamicTool] {
        if searchText.isEmpty { return dynamicManager.tools }
        let q = searchText.lowercased()
        return dynamicManager.tools.filter { $0.name.lowercased().contains(q) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // App Header
            HStack(spacing: 8) {
                Image(systemName: "briefcase.fill")
                    .font(.system(size: 14, weight: .semibold))
                
                Text("Toolcase")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                
                Spacer()
                
                Button(action: { AddToolWindowManager.shared.show(manager: dynamicManager) }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                        Text("Add Tool")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.1))
                    .foregroundColor(Color(white: 1))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)
            
            // Search Bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.6))
                
                TextField("Search tools...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 13))
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.primary.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
            
            // Content
            ScrollView {
                VStack(spacing: 0) {
                    // Standard Tools
                    if !filteredFeatures.isEmpty {
                        SectionHeader(title: "Standard Tools")
                        
                        VStack(spacing: 2) {
                            ForEach(filteredFeatures) { feature in
                                feature.view
                            }
                        }
                        .padding(.horizontal, 6)
                    }
                    
                    // Dynamic (User) Tools
                    if !filteredDynamicTools.isEmpty {
                        SectionHeader(title: "Your Tools")
                        
                        VStack(spacing: 2) {
                            ForEach(filteredDynamicTools) { tool in
                                MenuItemView(
                                    title: tool.name,
                                    icon: tool.icon,
                                    iconColor: .accentColor,
                                    shortcutText: tool.shortcutKey.isEmpty ? nil : "⌃⌥\(tool.shortcutKey)",
                                    action: { dynamicManager.run(tool: tool) }
                                ) {
                                    Button(action: {
                                        if let index = dynamicManager.tools.firstIndex(where: { $0.id == tool.id }) {
                                            dynamicManager.deleteTool(at: IndexSet(integer: index))
                                        }
                                    }) {
                                        Image(systemName: "trash")
                                            .font(.system(size: 10))
                                            .foregroundColor(.secondary.opacity(0.4))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, 6)
                    }
                    
                    // Empty State
                    if filteredFeatures.isEmpty && filteredDynamicTools.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 24))
                                .foregroundColor(.secondary.opacity(0.3))
                            Text("No results found")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                    
                    // Settings — only visible when not searching
                    if searchText.isEmpty {
                        SectionHeader(title: "Settings")
                        
                        VStack(spacing: 2) {
                            LaunchAtStartupMenuItem()
                            
                            MenuItemView(
                                title: "Quit Toolcase",
                                icon: "power",
                                iconColor: .red,
                                action: {
                                    NSApplication.shared.terminate(nil)
                                }
                            ) {
                                Text("⌘Q")
                                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                                    .foregroundColor(.secondary.opacity(0.5))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                                            .fill(Color.secondary.opacity(0.08))
                                    )
                            }
                        }
                        .padding(.horizontal, 6)
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .frame(width: 320, height: 420)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
    ContentView()
}
