import Foundation
import SwiftData

@Model
final class UserSettings {
    @Attribute(.unique) var id: UUID
    var theme: AppTheme
    var alarmSound: AlarmSound
    var defaultFeedType: FeedType
    var defaultFormulaType: String?
    var viewMode: TimerViewMode
    var hasUnlockedSync: Bool
    var hasCompletedOnboarding: Bool
    var selectedBabyID: UUID?
    
    init() {
        self.id = UUID()
        self.theme = .dark
        self.alarmSound = .softChime
        self.defaultFeedType = .both
        self.defaultFormulaType = nil
        self.viewMode = .countdown
        self.hasUnlockedSync = false
        self.hasCompletedOnboarding = false
        self.selectedBabyID = nil
    }
}
