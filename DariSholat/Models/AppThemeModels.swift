//
//  AppThemeModels.swift
//  DariSholat
//

import SwiftUI

// MARK: - App Blur Style

enum AppBlurStyle: String, CaseIterable, Identifiable {
    case hud = "hud"
    case popover = "popover"
    case menu = "menu"
    case sidebar = "sidebar"
    case liquidGlass = "liquidGlass"
    case custom = "custom"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .hud: return "HUD (Dark Glass)"
        case .popover: return "Popover (Light)"
        case .menu: return "Menu (Standard)"
        case .sidebar: return "Sidebar"
        case .liquidGlass: return "Liquid Glass"
        case .custom: return "Custom..."
        }
    }
}

// MARK: - Accent Color Preset

enum AppAccentColor: String, CaseIterable, Identifiable {
    case white  = "white"
    case green  = "green"
    case blue   = "blue"
    case purple = "purple"
    case orange = "orange"
    case red    = "red"
    case yellow = "yellow"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .white:  return "White (Default)"
        case .green:  return "Green"
        case .blue:   return "Blue"
        case .purple: return "Purple"
        case .orange: return "Orange"
        case .red:    return "Red"
        case .yellow: return "Yellow"
        }
    }

    var color: Color {
        switch self {
        case .white:  return Color.white
        case .green:  return Color(red: 0.196, green: 0.784, blue: 0.439)
        case .blue:   return Color(red: 0.20, green: 0.50, blue: 0.95)
        case .purple: return Color(red: 0.58, green: 0.34, blue: 0.92)
        case .orange: return Color(red: 0.95, green: 0.55, blue: 0.20)
        case .red:    return Color(red: 0.92, green: 0.28, blue: 0.28)
        case .yellow: return Color.yellow
        }
    }

    var swatchColor: Color {
        color
    }
}
