//
//  DesignTokens.swift
//  DariSholat
//
//  Layout tokens based on Golden Ratio & Fibonacci spacing:
//  φ = 1.618 | Fibonacci: 1,1,2,3,5,8,13,21,34,55,89...
//

import SwiftUI
import AppKit

// MARK: - Fibonacci / Golden Ratio Design Tokens

enum DS {
    // Fibonacci units
    static let f3:  CGFloat = 3
    static let f5:  CGFloat = 5
    static let f8:  CGFloat = 8
    static let f13: CGFloat = 13
    static let f21: CGFloat = 21
    static let f34: CGFloat = 34

    // Layout
    static let panelWidth:     CGFloat = 260          // 233+13+13 ≈ 260
    static let paddingH:       CGFloat = f13          // horizontal padding
    static let rowV:           CGFloat = f8           // row vertical padding
    static let headerV:        CGFloat = f13          // header vertical padding
    static let dividerOpacity: CGFloat = 0.35

    // Typography (Fibonacci-scaled)
    static let fontTitle:   CGFloat = 15            // ≈ 13 × φ
    static let fontBody:    CGFloat = f13
    static let fontSmall:   CGFloat = 11            // ≈ 8 × φ
    static let fontMono:    CGFloat = f13
}

// MARK: - DS global access extensions
extension CGFloat {
    static let paddingH:  CGFloat = DS.paddingH
    static let rowV:      CGFloat = DS.rowV
    static let headerV:   CGFloat = DS.headerV
    static let fontBody:  CGFloat = DS.fontBody
    static let fontSmall: CGFloat = DS.fontSmall
}

// MARK: - Blur Style Mapping
extension AppBlurStyle {
    var material: NSVisualEffectView.Material {
        switch self {
        case .hud:         return .hudWindow
        case .popover:     return .popover
        case .menu:        return .menu
        case .sidebar:     return .sidebar
        case .liquidGlass: return .underWindowBackground
        case .custom:      return .hudWindow // Base material for custom opacity
        }
    }
}

// MARK: - Typography Utilities
extension Font {
    /// Handwritten font with graceful fallback when Noteworthy is missing.
    static func handFont(_ size: CGFloat) -> Font {
        if NSFont(name: "Noteworthy-Light", size: size) != nil {
            return .custom("Noteworthy-Light", size: size)
        }
        return .system(size: size, weight: .regular, design: .rounded)
    }
}
