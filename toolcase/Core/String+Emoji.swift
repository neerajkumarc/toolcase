//
//  String+Emoji.swift
//  Toolcase
//
//  Copyright © 2025 Neeraj Kumar. All rights reserved.
//

import Foundation

extension String {
    /// Returns `true` if the string is a single emoji character (or emoji sequence).
    /// Used to distinguish emoji icons from SF Symbol names in tool configuration.
    var isEmoji: Bool {
        guard !isEmpty else { return false }
        // SF Symbol names are always pure ASCII (e.g. "bolt.fill", "mic.slash.fill")
        // Emojis contain non-ASCII unicode scalars with emoji properties
        return unicodeScalars.allSatisfy { scalar in
            scalar.properties.isEmoji && scalar.value > 0x23 // exclude ASCII symbols like #
        }
    }
}
