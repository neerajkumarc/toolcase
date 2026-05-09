//
//  ClipboardManager.swift
//  Toolcase
//
//  Copyright © 2025 Neeraj Kumar. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - ClipboardItem

/// Represents a single clipboard entry — either text or an image.
enum ClipboardItem: Identifiable, Equatable {
    case text(String)
    case image(Data, width: Int, height: Int)
    
    var id: String {
        switch self {
        case .text(let str):
            return "text-\(str.hashValue)"
        case .image(let data, _, _):
            return "image-\(data.hashValue)"
        }
    }
    
    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        switch (lhs, rhs) {
        case (.text(let a), .text(let b)):
            return a == b
        case (.image(let a, _, _), .image(let b, _, _)):
            return a == b
        default:
            return false
        }
    }
}

// MARK: - ClipboardManager

/// Polls the system pasteboard for changes and maintains a history of recent clipboard items.
class ClipboardManager: ObservableObject {
    static let shared = ClipboardManager()
    
    @Published var history: [ClipboardItem] = []
    
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let maxItems = 10
    
    /// Start polling the system pasteboard for changes.
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let pasteboard = NSPasteboard.general
            if pasteboard.changeCount != self.lastChangeCount {
                self.lastChangeCount = pasteboard.changeCount
                self.captureClipboard(pasteboard)
            }
        }
    }
    
    // MARK: - Private
    
    private func captureClipboard(_ pasteboard: NSPasteboard) {
        // Check for image first (TIFF is the universal macOS image pasteboard type)
        if let imgData = pasteboard.data(forType: .tiff),
           let nsImage = NSImage(data: imgData) {
            let w = Int(nsImage.size.width)
            let h = Int(nsImage.size.height)
            // Store as PNG for smaller size
            if let tiffRep = nsImage.tiffRepresentation,
               let bitmapRep = NSBitmapImageRep(data: tiffRep),
               let pngData = bitmapRep.representation(using: .png, properties: [:]) {
                addItem(.image(pngData, width: w, height: h))
                return
            }
        }
        
        // Fall back to text
        if let str = pasteboard.string(forType: .string) {
            let trimmed = str.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            addItem(.text(str))
        }
    }
    
    private func addItem(_ item: ClipboardItem) {
        DispatchQueue.main.async {
            if let index = self.history.firstIndex(of: item) {
                self.history.remove(at: index)
            }
            self.history.insert(item, at: 0)
            if self.history.count > self.maxItems {
                self.history.removeLast()
            }
        }
    }
}
