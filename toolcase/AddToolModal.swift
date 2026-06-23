//
//  AddToolModal.swift
//  Toolcase
//
//  Copyright © 2025 Neeraj Kumar. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - Curated SF Symbol list for search
struct SFSymbolLibrary {
    static let all: [(name: String, category: String)] = [
        // Development
        ("terminal.fill", "Dev"), ("chevron.left.forwardslash.chevron.right", "Dev"),
        ("cpu.fill", "Dev"), ("memorychip.fill", "Dev"), ("server.rack", "Dev"),
        ("externaldrive.fill", "Dev"), ("network", "Dev"), ("wifi", "Dev"),
        
        // Tools
        ("hammer.fill", "Tools"), ("wrench.and.screwdriver.fill", "Tools"),
        ("gearshape.fill", "Tools"), ("gearshape.2.fill", "Tools"),
        ("bolt.fill", "Tools"), ("bolt.circle.fill", "Tools"),
        ("screwdriver.fill", "Tools"), ("scissors", "Tools"),
        
        // Media
        ("mic.fill", "Media"), ("mic.slash.fill", "Media"),
        ("speaker.wave.3.fill", "Media"), ("speaker.slash.fill", "Media"),
        ("camera.fill", "Media"), ("video.fill", "Media"),
        ("play.fill", "Media"), ("pause.fill", "Media"),
        ("music.note", "Media"), ("headphones", "Media"),
        
        // Communication
        ("envelope.fill", "Comm"), ("paperplane.fill", "Comm"),
        ("bubble.left.fill", "Comm"), ("phone.fill", "Comm"),
        ("bell.fill", "Comm"), ("megaphone.fill", "Comm"),
        
        // Files & Data
        ("doc.fill", "Files"), ("doc.text.fill", "Files"),
        ("folder.fill", "Files"), ("tray.fill", "Files"),
        ("archivebox.fill", "Files"), ("trash.fill", "Files"),
        ("clipboard.fill", "Files"), ("list.clipboard.fill", "Files"),
        
        // Navigation & Web
        ("globe", "Web"), ("safari.fill", "Web"),
        ("link", "Web"), ("antenna.radiowaves.left.and.right", "Web"),
        ("icloud.fill", "Web"), ("arrow.down.circle.fill", "Web"),
        ("arrow.up.circle.fill", "Web"), ("arrow.clockwise", "Web"),
        
        // Security
        ("lock.fill", "Security"), ("lock.open.fill", "Security"),
        ("key.fill", "Security"), ("shield.fill", "Security"),
        ("hand.raised.fill", "Security"), ("eye.fill", "Security"),
        ("eye.slash.fill", "Security"), ("faceid", "Security"),
        
        // System
        ("power", "System"), ("battery.100", "System"),
        ("lightbulb.fill", "System"), ("moon.fill", "System"),
        ("sun.max.fill", "System"), ("display", "System"),
        ("keyboard", "System"), ("cursorarrow.click.2", "System"),
        
        // Shapes & Symbols
        ("star.fill", "Shapes"), ("heart.fill", "Shapes"),
        ("flame.fill", "Shapes"), ("leaf.fill", "Shapes"),
        ("drop.fill", "Shapes"), ("snowflake", "Shapes"),
        ("wand.and.stars", "Shapes"), ("sparkles", "Shapes"),
        ("paintbrush.fill", "Shapes"), ("eyedropper.halffull", "Shapes"),
        
        // Arrows & Actions
        ("square.and.arrow.up.fill", "Actions"), ("square.and.arrow.down.fill", "Actions"),
        ("arrow.right.circle.fill", "Actions"), ("checkmark.circle.fill", "Actions"),
        ("xmark.circle.fill", "Actions"), ("plus.circle.fill", "Actions"),
        ("minus.circle.fill", "Actions"), ("exclamationmark.triangle.fill", "Actions"),
        
        // People & Misc
        ("person.fill", "People"), ("person.2.fill", "People"),
        ("person.crop.circle.fill", "People"), ("figure.walk", "People"),
        ("clock.fill", "Misc"), ("timer", "Misc"),
        ("calendar", "Misc"), ("map.fill", "Misc"),
        ("location.fill", "Misc"), ("bookmark.fill", "Misc"),
        ("tag.fill", "Misc"), ("flag.fill", "Misc"),
        ("chart.bar.fill", "Misc"), ("gauge.medium", "Misc"),
    ]
    
    static func search(_ query: String) -> [(name: String, category: String)] {
        if query.isEmpty { return all }
        let q = query.lowercased()
        return all.filter { $0.name.lowercased().contains(q) || $0.category.lowercased().contains(q) }
    }
}

// MARK: - Curated Emoji Library
struct EmojiLibrary {
    static let categories: [(name: String, emojis: [String])] = [
        ("Smileys", ["😀", "😎", "🤩", "🥳", "😈", "🤖", "👻", "💀", "🤯", "🧐"]),
        ("Hands", ["👋", "🤝", "👍", "👎", "✌️", "🤞", "👊", "✊", "🫶", "🙌"]),
        ("Animals", ["🐶", "🐱", "🦊", "🐻", "🐼", "🐨", "🦁", "🐸", "🐙", "🦋"]),
        ("Food", ["☕", "🍕", "🍔", "🌮", "🍣", "🍩", "🧁", "🍺", "🥤", "🍎"]),
        ("Objects", ["💻", "📱", "⌨️", "🖥️", "🎮", "🕹️", "📷", "🔧", "🔨", "⚙️"]),
        ("Tech", ["🚀", "⚡", "💡", "🔥", "✨", "💎", "🧪", "🧬", "🔬", "🛰️"]),
        ("Nature", ["🌈", "🌊", "🌸", "🌻", "🍀", "🌙", "⭐", "☀️", "❄️", "🔮"]),
        ("Flags", ["🏁", "🚩", "🎌", "🏴", "🏳️", "🇺🇸", "🇬🇧", "🇯🇵", "🇮🇳", "🇩🇪"]),
        ("Symbols", ["❤️", "💜", "💙", "💚", "💛", "🧡", "🤍", "🖤", "♻️", "⚠️"]),
        ("Fun", ["🎯", "🎲", "🎪", "🎨", "🎵", "🎬", "🏆", "🎁", "🎈", "🎉"]),
    ]

    static var all: [String] {
        categories.flatMap { $0.emojis }
    }

    static func search(_ query: String) -> [String] {
        if query.isEmpty { return all }
        let q = query.lowercased()
        // Search by category name
        let matched = categories.filter { $0.name.lowercased().contains(q) }.flatMap { $0.emojis }
        return matched.isEmpty ? all : matched
    }
}

// MARK: - Icon Mode
enum IconMode: String, CaseIterable {
    case sfSymbol = "SF Symbol"
    case emoji = "Emoji"
}

// MARK: - AddToolWindow Manager
class AddToolWindowManager {
    static let shared = AddToolWindowManager()
    private var window: NSWindow?
    
    func show(manager: DynamicToolManager, editingTool: DynamicTool? = nil) {
        if window == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 650),
                styleMask: [.titled, .closable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            window.isMovableByWindowBackground = true
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.level = .floating
            window.isReleasedWhenClosed = false
            window.center()
            self.window = window
        }
        
        let view = NSHostingView(rootView: AddToolView(manager: manager, editingTool: editingTool, onDismiss: { [weak self] in
            self?.window?.orderOut(nil)
        }))
        window?.contentView = view
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func hide() {
        window?.orderOut(nil)
    }
}

// MARK: - Add Tool View (standalone, no sheet)
struct AddToolView: View {
    @ObservedObject var manager: DynamicToolManager
    var editingTool: DynamicTool? = nil
    var onDismiss: () -> Void
    
    @State private var name: String
    @State private var icon: String
    @State private var code: String
    @State private var iconSearch = ""
    @State private var emojiSearch = ""
    @State private var showIconPicker = false
    @State private var shortcutKey: String
    @State private var iconMode: IconMode
    @State private var isPromptCopied = false
    
    init(manager: DynamicToolManager, editingTool: DynamicTool? = nil, onDismiss: @escaping () -> Void) {
        self.manager = manager
        self.editingTool = editingTool
        self.onDismiss = onDismiss
        
        if let editingTool = editingTool {
            _name = State(initialValue: editingTool.name)
            _icon = State(initialValue: editingTool.icon)
            _code = State(initialValue: editingTool.code)
            _shortcutKey = State(initialValue: editingTool.shortcutKey)
            _iconMode = State(initialValue: editingTool.icon.isEmoji ? .emoji : .sfSymbol)
        } else {
            _name = State(initialValue: "")
            _icon = State(initialValue: "bolt.fill")
            _code = State(initialValue: """
// Write your Swift code here.
// It runs as a standalone script via /usr/bin/swift.
//
// Available frameworks: Foundation, Cocoa, etc.
//
// Example: Open a website
import Cocoa
NSWorkspace.shared.open(URL(string: "https://google.com")!)
""")
            _shortcutKey = State(initialValue: "")
            _iconMode = State(initialValue: .sfSymbol)
        }
    }
    
    private var filteredIcons: [(name: String, category: String)] {
        SFSymbolLibrary.search(iconSearch)
    }
    
    private var filteredEmojis: [String] {
        EmojiLibrary.search(emojiSearch)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: editingTool != nil ? "pencil" : "plus.rectangle.fill")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 16))
                Text(editingTool != nil ? "Edit Tool" : "Add New Tool")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 20))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.primary.opacity(0.03))
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Name Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TOOL NAME")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                            .tracking(0.8)
                        
                        TextField("e.g., Open Google, Toggle Dark Mode...", text: $name)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 14))
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.primary.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                            )
                    }
                    
                    // Icon Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("ICON")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.secondary)
                                .tracking(0.8)
                            
                            Spacer()
                            
                            // Mode Switcher
                            Picker("", selection: $iconMode) {
                                ForEach(IconMode.allCases, id: \.self) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 170)
                            .onChange(of: iconMode) { _, newMode in
                                // Set a sensible default when switching
                                if newMode == .emoji && !icon.isEmoji {
                                    icon = "🚀"
                                } else if newMode == .sfSymbol && icon.isEmoji {
                                    icon = "bolt.fill"
                                }
                            }
                        }
                        
                        HStack(spacing: 12) {
                            // Selected icon preview
                            if icon.isEmoji {
                                Text(icon)
                                    .font(.system(size: 22))
                                    .frame(width: 38, height: 38)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.primary.opacity(0.06))
                                    )
                            } else {
                                Image(systemName: icon)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 38, height: 38)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.accentColor.gradient)
                                    )
                            }
                            
                            // Picker trigger button
                            Button(action: { showIconPicker.toggle() }) {
                                HStack(spacing: 6) {
                                    if iconMode == .emoji {
                                        Text(icon)
                                            .font(.system(size: 14))
                                    }
                                    Text(iconMode == .emoji ? "Change Emoji" : icon)
                                        .font(.system(size: 11, design: iconMode == .emoji ? .default : .monospaced))
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.primary.opacity(0.05))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            .popover(isPresented: $showIconPicker, arrowEdge: .bottom) {
                                if iconMode == .sfSymbol {
                                    IconPickerPopover(selectedIcon: $icon, iconSearch: $iconSearch, filteredIcons: filteredIcons)
                                } else {
                                    EmojiPickerPopover(selectedEmoji: $icon, emojiSearch: $emojiSearch, filteredEmojis: filteredEmojis)
                                }
                            }
                        }
                    }
                    
                    // Shortcut Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("KEYBOARD SHORTCUT")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                            .tracking(0.8)
                        
                        HStack(spacing: 12) {
                            // Modifier badge
                            HStack(spacing: 4) {
                                Text("⌃")
                                    .font(.system(size: 14, weight: .medium))
                                Text("⌥")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.primary.opacity(0.05))
                            )
                            
                            Text("+")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14, weight: .medium))
                            
                            // Key input
                            TextField("Key (e.g. G)", text: $shortcutKey)
                                .textFieldStyle(PlainTextFieldStyle())
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                                .frame(width: 80)
                                .multilineTextAlignment(.center)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.primary.opacity(0.05))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                                )
                                .onChange(of: shortcutKey) { _, newValue in
                                    // Only allow single character, uppercase
                                    let filtered = newValue.uppercased().filter { $0.isLetter || $0.isNumber }
                                    shortcutKey = String(filtered.prefix(1))
                                }
                            
                            Spacer()
                            
                            // Validation
                            if !shortcutKey.isEmpty {
                                if DynamicToolManager.reservedKeys.contains(shortcutKey) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.system(size: 10))
                                        Text("Reserved")
                                            .font(.system(size: 10, weight: .medium))
                                    }
                                    .foregroundColor(.orange)
                                } else if !manager.isKeyAvailable(shortcutKey, excluding: editingTool?.id) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.system(size: 10))
                                        Text("In use")
                                            .font(.system(size: 10, weight: .medium))
                                    }
                                    .foregroundColor(.orange)
                                } else {
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 10))
                                        Text("Available")
                                            .font(.system(size: 10, weight: .medium))
                                    }
                                    .foregroundColor(.green)
                                }
                            } else {
                                Text("Optional")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.secondary.opacity(0.5))
                            }
                        }
                    }
                    
                    // Code Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("SWIFT CODE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.secondary)
                                .tracking(0.8)
                            Spacer()
                            
                            Button(action: {
                                // Copy the LLM prompt template to clipboard
                                let template = """
I'm using a macOS menu bar app called "Toolcase" that lets me add custom tools as Swift scripts.

Each tool is a standalone Swift script that runs via `/usr/bin/swift` on macOS.
The script runs as a regular process (not sandboxed), so it has access to:
- Foundation, Cocoa, AppKit
- NSWorkspace, FileManager, Process, NSPasteboard
- Shell commands via Process()
- Network requests via URLSession
- NSAppleScript for AppleScript

RULES:
1. The script must be a top-level Swift file (no @main, no struct App, no SwiftUI App lifecycle).
2. Import any needed frameworks at the top (e.g. `import Cocoa`, `import Foundation`).
3. The script runs and exits — keep it short and focused.
4. For async work, use DispatchGroup or RunLoop to keep the process alive until done.
5. Use `print()` to output results (they appear in Console.app logs).
6. To copy something to clipboard: `NSPasteboard.general.clearContents(); NSPasteboard.general.setString("value", forType: .string)`
7. To open URLs/files: `NSWorkspace.shared.open(URL(...))`
8. To run shell commands: Use `Process()` with `/bin/zsh` or specific executables.

PLEASE GENERATE A SWIFT SCRIPT THAT DOES THE FOLLOWING:

[DESCRIBE WHAT YOU WANT HERE]

Return ONLY the Swift code, no explanation.
"""
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(template, forType: .string)
                                withAnimation {
                                    isPromptCopied = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        isPromptCopied = false
                                    }
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: isPromptCopied ? "checkmark" : "doc.on.doc")
                                        .font(.system(size: 9))
                                    Text(isPromptCopied ? "Copied!" : "Copy LLM Prompt")
                                        .font(.system(size: 9, weight: .semibold))
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(isPromptCopied ? Color.green.opacity(0.12) : Color.orange.opacity(0.12))
                                .foregroundColor(isPromptCopied ? .green : .orange)
                                .cornerRadius(4)
                            }
                            .buttonStyle(.plain)
                            .help("Copy a prompt template you can paste into ChatGPT, Claude, etc.")
                            
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 6, height: 6)
                                Text("Runs via /usr/bin/swift")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.secondary.opacity(0.6))
                            }
                        }
                        
                        TextEditor(text: $code)
                            .font(.system(size: 12, design: .monospaced))
                            .frame(height: 180)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(NSColor.textBackgroundColor).opacity(0.5))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                            )
                    }
                }
                .padding(20)
            }
            
            Divider()
            
            // Footer
            HStack {
                Button(action: onDismiss) {
                    Text("Cancel")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.primary.opacity(0.05))
                        )
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button(action: {
                    if !name.isEmpty {
                        if let editingTool = editingTool {
                            manager.updateTool(id: editingTool.id, name: name, icon: icon, code: code, shortcutKey: shortcutKey)
                        } else {
                            manager.addTool(name: name, icon: icon, code: code, shortcutKey: shortcutKey)
                        }
                        onDismiss()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: editingTool != nil ? "checkmark.circle.fill" : "plus.circle.fill")
                            .font(.system(size: 12))
                        Text(editingTool != nil ? "Save Changes" : "Add Tool")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(name.isEmpty ? Color.gray : Color.accentColor)
                    )
                }
                .buttonStyle(.plain)
                .disabled(name.isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .frame(width: 500, height: 650)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - Icon Picker Popover
struct IconPickerPopover: View {
    @Binding var selectedIcon: String
    @Binding var iconSearch: String
    let filteredIcons: [(name: String, category: String)]
    
    var body: some View {
        VStack(spacing: 0) {
            // Search
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.5))
                
                TextField("Search icons...", text: $iconSearch)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.primary.opacity(0.04))
            
            Divider()
            
            // Grid
            ScrollView {
                let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 6)
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(filteredIcons, id: \.name) { item in
                        Button(action: { selectedIcon = item.name }) {
                            Image(systemName: item.name)
                                .font(.system(size: 16))
                                .frame(width: 36, height: 36)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(selectedIcon == item.name ? Color.accentColor : Color.primary.opacity(0.04))
                                )
                                .foregroundColor(selectedIcon == item.name ? .white : .primary)
                        }
                        .buttonStyle(.plain)
                        .help(item.name)
                    }
                }
                .padding(8)
            }
        }
        .frame(width: 280, height: 300)
    }
}

// MARK: - Emoji Picker Popover
struct EmojiPickerPopover: View {
    @Binding var selectedEmoji: String
    @Binding var emojiSearch: String
    let filteredEmojis: [String]
    
    var body: some View {
        VStack(spacing: 0) {
            // Search by category
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.5))
                
                TextField("Search by category...", text: $emojiSearch)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.primary.opacity(0.04))
            
            Divider()
            
            // Custom emoji input
            HStack(spacing: 8) {
                Text("Custom:")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                
                TextField("Paste any emoji", text: $selectedEmoji)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity)
                    .onChange(of: selectedEmoji) { _, newValue in
                        // Keep only the first emoji character/sequence
                        if !newValue.isEmpty {
                            let first = String(newValue.prefix(2))
                            if first != newValue {
                                selectedEmoji = first
                            }
                        }
                    }
                
                if selectedEmoji.isEmoji {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.primary.opacity(0.02))
            
            Divider()
            
            // Emoji Grid
            ScrollView {
                let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(filteredEmojis, id: \.self) { emoji in
                        Button(action: { selectedEmoji = emoji }) {
                            Text(emoji)
                                .font(.system(size: 20))
                                .frame(width: 34, height: 34)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(selectedEmoji == emoji ? Color.accentColor.opacity(0.25) : Color.clear)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(8)
            }
        }
        .frame(width: 290, height: 340)
    }
}
