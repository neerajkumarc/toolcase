//
//  DynamicToolManager.swift
//  Toolcase
//
//  Copyright © 2025 Neeraj Kumar. All rights reserved.
//

import SwiftUI
import Combine
import Carbon.HIToolbox

/// A user-created tool stored as a Swift script.
struct DynamicTool: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: String
    var code: String
    var shortcutKey: String
    var dateAdded: Date
    
    init(id: UUID = UUID(), name: String, icon: String, code: String, shortcutKey: String = "", dateAdded: Date = Date()) {
        self.id = id
        self.name = name
        self.icon = icon
        self.code = code
        self.shortcutKey = shortcutKey.uppercased()
        self.dateAdded = dateAdded
    }
}

private let charToKeyCode: [Character: UInt32] = [
    "A": UInt32(kVK_ANSI_A), "B": UInt32(kVK_ANSI_B), "C": UInt32(kVK_ANSI_C),
    "D": UInt32(kVK_ANSI_D), "E": UInt32(kVK_ANSI_E), "F": UInt32(kVK_ANSI_F),
    "G": UInt32(kVK_ANSI_G), "H": UInt32(kVK_ANSI_H), "I": UInt32(kVK_ANSI_I),
    "J": UInt32(kVK_ANSI_J), "K": UInt32(kVK_ANSI_K), "L": UInt32(kVK_ANSI_L),
    "N": UInt32(kVK_ANSI_N), "O": UInt32(kVK_ANSI_O),
    "Q": UInt32(kVK_ANSI_Q), "R": UInt32(kVK_ANSI_R), "S": UInt32(kVK_ANSI_S),
    "T": UInt32(kVK_ANSI_T), "U": UInt32(kVK_ANSI_U),
    "W": UInt32(kVK_ANSI_W), "X": UInt32(kVK_ANSI_X),
    "Y": UInt32(kVK_ANSI_Y), "Z": UInt32(kVK_ANSI_Z),
    "0": UInt32(kVK_ANSI_0), "1": UInt32(kVK_ANSI_1), "2": UInt32(kVK_ANSI_2),
    "3": UInt32(kVK_ANSI_3), "4": UInt32(kVK_ANSI_4), "5": UInt32(kVK_ANSI_5),
    "6": UInt32(kVK_ANSI_6), "7": UInt32(kVK_ANSI_7), "8": UInt32(kVK_ANSI_8),
    "9": UInt32(kVK_ANSI_9),
]

/// Manages user-created tools: persistence, execution, and hotkey registration.
class DynamicToolManager: ObservableObject {
    static let shared = DynamicToolManager()
    static let reservedKeys: Set<String> = ["P", "V", "M"]
    
    @Published var tools: [DynamicTool] = []
    
    private let storageKey = "dynamic_tools_v2"
    private var hotkeyRefs: [UUID: EventHotKeyRef] = [:]
    private var nextHotkeyID: UInt32 = 100
    private var toolIDByHotkeyID: [UInt32: UUID] = [:]
    
    init() { loadTools() }
    
    func addTool(name: String, icon: String, code: String, shortcutKey: String = "") {
        let tool = DynamicTool(name: name, icon: icon, code: code, shortcutKey: shortcutKey)
        tools.append(tool)
        saveTools()
        if !tool.shortcutKey.isEmpty { registerHotkey(for: tool) }
    }
    
    func updateTool(id: UUID, name: String, icon: String, code: String, shortcutKey: String) {
        if let index = tools.firstIndex(where: { $0.id == id }) {
            unregisterHotkey(for: tools[index])
            tools[index].name = name
            tools[index].icon = icon
            tools[index].code = code
            tools[index].shortcutKey = shortcutKey.uppercased()
            saveTools()
            if !tools[index].shortcutKey.isEmpty { registerHotkey(for: tools[index]) }
        }
    }
    
    func deleteTool(at offsets: IndexSet) {
        for i in offsets { unregisterHotkey(for: tools[i]) }
        tools.remove(atOffsets: offsets)
        saveTools()
    }
    
    func isKeyAvailable(_ key: String, excluding toolId: UUID? = nil) -> Bool {
        let k = key.uppercased()
        if Self.reservedKeys.contains(k) { return false }
        return !tools.contains(where: { $0.shortcutKey == k && $0.id != toolId })
    }
    
    func run(tool: DynamicTool) {
        DispatchQueue.global(qos: .userInitiated).async {
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(tool.id.uuidString).swift")
            do {
                var code = tool.code
                if !code.contains("import Cocoa") && !code.contains("import Foundation") {
                    code = "import Cocoa\nimport Foundation\n" + code
                }
                try code.write(to: fileURL, atomically: true, encoding: .utf8)
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
                process.arguments = [fileURL.path]
                let out = Pipe(), err = Pipe()
                process.standardOutput = out
                process.standardError = err
                try process.run()
                process.waitUntilExit()
                if let o = String(data: out.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8), !o.isEmpty { print("[Toolcase] \(o)") }
                if let e = String(data: err.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8), !e.isEmpty { print("[Toolcase] Error: \(e)") }
                try? FileManager.default.removeItem(at: fileURL)
            } catch { print("[Toolcase] Failed: \(error)") }
        }
    }
    
    func registerAllHotkeys() {
        for tool in tools where !tool.shortcutKey.isEmpty { registerHotkey(for: tool) }
    }
    
    func handleHotkey(id: UInt32) -> Bool {
        guard let uuid = toolIDByHotkeyID[id], let tool = tools.first(where: { $0.id == uuid }) else { return false }
        run(tool: tool)
        return true
    }
    
    private func registerHotkey(for tool: DynamicTool) {
        guard let char = tool.shortcutKey.uppercased().first, let keyCode = charToKeyCode[char] else { return }
        let sig = OSType(0x544F4F4C), mods: UInt32 = UInt32(controlKey | optionKey)
        let hkID = nextHotkeyID; nextHotkeyID += 1
        var ref: EventHotKeyRef?
        if RegisterEventHotKey(keyCode, mods, EventHotKeyID(signature: sig, id: hkID), GetApplicationEventTarget(), 0, &ref) == noErr, let r = ref {
            hotkeyRefs[tool.id] = r; toolIDByHotkeyID[hkID] = tool.id
        }
    }
    
    private func unregisterHotkey(for tool: DynamicTool) {
        if let ref = hotkeyRefs[tool.id] { UnregisterEventHotKey(ref); hotkeyRefs.removeValue(forKey: tool.id); toolIDByHotkeyID = toolIDByHotkeyID.filter { $0.value != tool.id } }
    }
    
    private func saveTools() { if let d = try? JSONEncoder().encode(tools) { UserDefaults.standard.set(d, forKey: storageKey) } }
    private func loadTools() { if let d = UserDefaults.standard.data(forKey: storageKey), let t = try? JSONDecoder().decode([DynamicTool].self, from: d) { tools = t } }
}
