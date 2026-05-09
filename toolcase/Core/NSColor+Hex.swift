//
//  NSColor+Hex.swift
//  Toolcase
//
//  Copyright © 2025 Neeraj Kumar. All rights reserved.
//

import AppKit

extension NSColor {
    /// Converts the color to a hex string (e.g., "#FF5733").
    func toHex() -> String? {
        guard let rgbColor = usingColorSpace(.sRGB) else { return nil }
        let red = Int(round(rgbColor.redComponent * 255))
        let green = Int(round(rgbColor.greenComponent * 255))
        let blue = Int(round(rgbColor.blueComponent * 255))
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}
