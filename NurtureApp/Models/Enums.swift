import Foundation
import SwiftUI

// MARK: - Feed Type
enum FeedType: String, Codable, CaseIterable, Identifiable {
    case left = "Left"
    case right = "Right"
    case both = "Both"
    case bottle = "Bottle"
    case formula = "Formula"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .left, .right, .both: return "🤱"
        case .bottle: return "🍼"
        case .formula: return "🍼"
        }
    }
    
    var color: Color {
        switch self {
        case .left, .right, .both: return .accentColor
        case .bottle, .formula: return .orange
        }
    }
}

// MARK: - Diaper Type
enum DiaperType: String, Codable, CaseIterable, Identifiable {
    case wet = "Wet"
    case dirty = "Dirty"
    case both = "Both"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .wet: return "💧"
        case .dirty: return "💩"
        case .both: return "💧💩"
        }
    }
    
    var color: Color {
        switch self {
        case .wet: return .blue
        case .dirty: return .brown
        case .both: return .purple
        }
    }
}

// MARK: - App Theme
enum AppTheme: String, Codable, CaseIterable, Identifiable {
    case dark = "Dark"
    case light = "Light"
    case system = "System"
    
    var id: String { rawValue }
}

// MARK: - Alarm Sound
enum AlarmSound: String, Codable, CaseIterable, Identifiable {
    case softChime = "Soft Chime"
    case gentleBell = "Gentle Bell"
    case harp = "Harp"
    case silent = "Silent"
    
    var id: String { rawValue }
    
    var fileName: String? {
        switch self {
        case .softChime: return "chime1"
        case .gentleBell: return "chime2"
        case .harp: return "chime3"
        case .silent: return nil
        }
    }
}

// MARK: - Timer View Mode
enum TimerViewMode: String, Codable, Identifiable {
    case countdown = "Countdown"
    case stopwatch = "Stopwatch"
    
    var id: String { rawValue }
}
