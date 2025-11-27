import SwiftUI

struct Theme {
    
    struct Dark {
        static let background = Color(hex: "1e1e2e")      // Deep purple-gray
        static let surface = Color(hex: "313244")         // Elevated surface
        static let textPrimary = Color(hex: "cdd6f4")     // Off-white
        static let textSecondary = Color(hex: "a6adc8")   // Muted
        static let accent = Color(hex: "89b4fa")          // Soft blue
        static let accentSecondary = Color(hex: "cba6f7") // Soft purple
        static let danger = Color(hex: "f38ba8")          // Soft red
        static let success = Color(hex: "a6e3a1")         // Soft green
    }
    
    struct Light {
        static let background = Color(hex: "eff1f5")
        static let surface = Color.white
        static let textPrimary = Color(hex: "4c4f69")
        static let textSecondary = Color(hex: "6c6f85")
        static let accent = Color(hex: "1e66f5")
        static let accentSecondary = Color(hex: "8839ef")
        static let danger = Color(hex: "d20f39")
        static let success = Color(hex: "40a02b")
    }
    
    static func background(for theme: AppTheme, colorScheme: ColorScheme) -> Color {
        switch theme {
        case .dark: return Dark.background
        case .light: return Light.background
        case .system: return colorScheme == .dark ? Dark.background : Light.background
        }
    }
    
    static func surface(for theme: AppTheme, colorScheme: ColorScheme) -> Color {
        switch theme {
        case .dark: return Dark.surface
        case .light: return Light.surface
        case .system: return colorScheme == .dark ? Dark.surface : Light.surface
        }
    }
    
    static func textPrimary(for theme: AppTheme, colorScheme: ColorScheme) -> Color {
        switch theme {
        case .dark: return Dark.textPrimary
        case .light: return Light.textPrimary
        case .system: return colorScheme == .dark ? Dark.textPrimary : Light.textPrimary
        }
    }
}
