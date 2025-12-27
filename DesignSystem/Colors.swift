//
//  Colors.swift
//  FormativeiOS
//
//  Design System - Color Palette
//

import SwiftUI

extension Color {
    // MARK: - Brand Colors
    static let brandPrimary = Color(hex: "6366F1")      // Indigo 500
    static let brandPrimaryDark = Color(hex: "4F46E5")  // Indigo 600
    static let brandPrimaryLight = Color(hex: "A5B4FC")  // Indigo 300
    static let brandSecondary = Color(hex: "EC4899")    // Pink 500
    
    // MARK: - Semantic Colors
    static let success = Color(hex: "10B981")           // Emerald 500
    static let warning = Color(hex: "F59E0B")           // Amber 500
    static let error = Color(hex: "EF4444")              // Red 500
    
    // MARK: - Background Colors
    static let background = Color(hex: "FAFAFA")         // Light mode
    static let backgroundDark = Color(hex: "09090B")     // Dark mode
    
    // MARK: - Surface Colors
    static let surface = Color(hex: "FFFFFF")            // Light mode
    static let surfaceDark = Color(hex: "18181B")        // Dark mode
    static let surfaceElevated = Color(hex: "1C1C1E")    // Dark mode elevated
    static let surfaceHigher = Color(hex: "2C2C2E")      // Dark mode higher
    
    // MARK: - Text Colors
    static let textPrimary = Color(hex: "18181B")        // Light mode
    static let textPrimaryDark = Color(hex: "FAFAFA")    // Dark mode
    static let textSecondary = Color(hex: "71717A")      // Both modes
    
    // MARK: - Separator
    static let separator = Color(hex: "38383A")          // Dark mode
    
    // MARK: - Initializer from hex
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Adaptive Colors
extension Color {
    static func adaptiveBackground() -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: "09090B")
                : UIColor(hex: "FAFAFA")
        })
    }
    
    static func adaptiveSurface() -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: "18181B")
                : UIColor(hex: "FFFFFF")
        })
    }
    
    static func adaptiveTextPrimary() -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: "FAFAFA")
                : UIColor(hex: "18181B")
        })
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

