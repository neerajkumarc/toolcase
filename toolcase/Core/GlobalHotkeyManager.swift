//
//  GlobalHotkeyManager.swift
//  Toolcase
//
//  Copyright © 2025 Neeraj Kumar. All rights reserved.
//

import SwiftUI
import Carbon.HIToolbox

// MARK: - Hotkey IDs
// Each registered hotkey gets a unique ID. Dynamic tools start at 100+.

private let kHotkeyColorPicker: UInt32 = 1
private let kHotkeyClipboard: UInt32   = 2
private let kHotkeyMicToggle: UInt32   = 3

// MARK: - Carbon Callback

/// Global C callback for Carbon hotkey events.
/// Uses the Carbon Event Manager — the most reliable approach for system-wide hotkeys.
/// Used by Alfred, Raycast, etc. Does NOT require Accessibility permissions.
private func carbonHotkeyHandler(
    nextHandler: EventHandlerCallRef?,
    event: EventRef?,
    userData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard let event = event else { return OSStatus(eventNotHandledErr) }
    
    var hotkeyID = EventHotKeyID()
    let status = GetEventParameter(
        event,
        UInt32(kEventParamDirectObject),
        UInt32(typeEventHotKeyID),
        nil,
        MemoryLayout<EventHotKeyID>.size,
        nil,
        &hotkeyID
    )
    
    guard status == noErr else { return OSStatus(eventNotHandledErr) }
    
    switch hotkeyID.id {
    case kHotkeyColorPicker:
        DispatchQueue.main.async { GlobalHotkeyManager.shared.triggerColorPicker() }
    case kHotkeyClipboard:
        DispatchQueue.main.async { OverlayManager.shared.showClipboardHistory() }
    case kHotkeyMicToggle:
        DispatchQueue.main.async { GlobalHotkeyManager.shared.triggerMicToggle() }
    default:
        // Check if it's a dynamic tool hotkey
        if DynamicToolManager.shared.handleHotkey(id: hotkeyID.id) {
            return noErr
        }
        return OSStatus(eventNotHandledErr)
    }
    
    return noErr
}

// MARK: - GlobalHotkeyManager

/// Registers system-wide keyboard shortcuts using the Carbon `RegisterEventHotKey` API.
/// All shortcuts use ⌃⌥ (Control + Option) as the modifier combination.
class GlobalHotkeyManager {
    static let shared = GlobalHotkeyManager()
    
    private var hotkeyRefs: [EventHotKeyRef?] = []
    
    func start() {
        registerCarbonHotkeys()
        print("[Toolcase] Global hotkeys registered via Carbon API.")
    }
    
    // MARK: - Actions
    
    func triggerMicToggle() {
        let isMuted = AudioManager.shared.toggleMic()
        if isMuted {
            OverlayManager.shared.showToast(icon: "mic.slash.fill", iconColor: .red)
        } else {
            OverlayManager.shared.showToast(icon: "mic.fill", iconColor: .green)
        }
    }
    
    func triggerColorPicker() {
        let sampler = NSColorSampler()
        sampler.show { selectedColor in
            if let nsColor = selectedColor, let hex = nsColor.toHex() {
                DispatchQueue.main.async {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(hex, forType: .string)
                    OverlayManager.shared.showColorToast(hex: hex, color: Color(nsColor: nsColor))
                }
            }
        }
    }
    
    // MARK: - Private Registration
    
    private func registerCarbonHotkeys() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        
        InstallEventHandler(
            GetApplicationEventTarget(),
            carbonHotkeyHandler,
            1,
            &eventType,
            nil,
            nil
        )
        
        // The 'signature' is a 4-char code identifying our app's hotkeys
        let signature = OSType(0x544F4F4C) // "TOOL" in hex
        
        // Control + Option modifiers in Carbon
        let modifiers: UInt32 = UInt32(controlKey | optionKey)
        
        // ⌃⌥P — Color Picker
        registerHotkey(id: kHotkeyColorPicker, keyCode: UInt32(kVK_ANSI_P), modifiers: modifiers, signature: signature)
        
        // ⌃⌥V — Clipboard History
        registerHotkey(id: kHotkeyClipboard, keyCode: UInt32(kVK_ANSI_V), modifiers: modifiers, signature: signature)
        
        // ⌃⌥M — Mic Toggle
        registerHotkey(id: kHotkeyMicToggle, keyCode: UInt32(kVK_ANSI_M), modifiers: modifiers, signature: signature)
    }
    
    private func registerHotkey(id: UInt32, keyCode: UInt32, modifiers: UInt32, signature: OSType) {
        let hotkeyID = EventHotKeyID(signature: signature, id: id)
        var hotkeyRef: EventHotKeyRef?
        
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotkeyID,
            GetApplicationEventTarget(),
            0,
            &hotkeyRef
        )
        
        if status == noErr {
            hotkeyRefs.append(hotkeyRef)
            print("[Toolcase] Registered hotkey id=\(id) keyCode=\(keyCode)")
        } else {
            print("[Toolcase] Failed to register hotkey id=\(id) status=\(status)")
        }
    }
}
