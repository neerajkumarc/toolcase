//
//  OverlayManager.swift
//  Toolcase
//
//  Copyright © 2025 Neeraj Kumar. All rights reserved.
//

import SwiftUI

/// Manages floating overlay windows for toasts and the clipboard history panel.
class OverlayManager {
    static let shared = OverlayManager()
    
    private var toastWindow: NSWindow?
    private var clipboardWindow: NSWindow?
    
    // MARK: - Toast
    
    func showToast(icon: String, iconColor: Color) {
        presentToast(content: AnyView(ToastView(icon: icon, iconColor: iconColor)))
    }
    
    func showColorToast(hex: String, color: Color) {
        presentToast(content: AnyView(ColorToastView(hex: hex, color: color)))
    }
    
    // MARK: - Clipboard History
    
    func showClipboardHistory() {
        if clipboardWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 350),
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
            window.collectionBehavior = .canJoinAllSpaces
            clipboardWindow = window
        }
        
        let view = NSHostingView(rootView: ClipboardHistoryView())
        clipboardWindow?.contentView = view
        clipboardWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func hideClipboardHistory() {
        clipboardWindow?.orderOut(nil)
    }
    
    // MARK: - Private
    
    private func presentToast(content: AnyView) {
        if toastWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: .zero, height: .zero),
                styleMask: .borderless,
                backing: .buffered,
                defer: false
            )
            window.isOpaque = false
            window.backgroundColor = .clear
            window.level = .floating
            window.ignoresMouseEvents = true
            toastWindow = window
        }
        
        let view = NSHostingView(rootView: content)
        toastWindow?.contentView = view
        
        if let screen = NSScreen.main {
            DispatchQueue.main.async {
                if let tw = self.toastWindow {
                    let screenRect = screen.visibleFrame
                    tw.setFrameOrigin(NSPoint(
                        x: screenRect.midX - (tw.frame.width / 2.0),
                        y: screenRect.minY + 60
                    ))
                }
            }
        }
        
        toastWindow?.orderFrontRegardless()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.toastWindow?.orderOut(nil)
        }
    }
}
