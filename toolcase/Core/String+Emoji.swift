//
//  String+Emoji.swift
//  Toolcase
//
//  Copyright © 2025 Neeraj Kumar. All rights reserved.
//

import Foundation

extension String {
    /// Returns `true` if the string contains an emoji or custom character.
    /// Used to distinguish emoji icons from SF Symbol names in tool configuration.
    var isEmoji: Bool {
        guard !isEmpty else { return false }
        // SF Symbol names consist only of standard ASCII characters (e.g. "bolt.fill", "mic.slash.fill").
        // Emojis and custom characters contain non-ASCII scalars or emoji properties.
        return unicodeScalars.contains { scalar in
            let val = scalar.value
            if val > 127 {
                return true
            }
            return scalar.properties.isEmoji && val > 0x39 // Exclude ASCII digits 0-9
        }
    }
}
