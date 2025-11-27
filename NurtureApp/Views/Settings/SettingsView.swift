import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var manager: NurtureManager
    
    var body: some View {
        Form {
            Section(header: Text("Timer")) {
                if let baby = manager.currentBaby {
                    Picker("Feed Interval", selection: Binding(
                        get: { baby.feedIntervalMinutes },
                        set: { baby.feedIntervalMinutes = $0 }
                    )) {
                        Text("2 Hours").tag(120)
                        Text("2.5 Hours").tag(150)
                        Text("3 Hours").tag(180)
                        Text("4 Hours").tag(240)
                    }
                }
            }
            
            Section(header: Text("Appearance")) {
                Picker("Theme", selection: Binding(
                    get: { manager.userSettings?.theme ?? .dark },
                    set: { manager.userSettings?.theme = $0 }
                )) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
            }
            
            Section(header: Text("Notifications")) {
                Picker("Alarm Sound", selection: Binding(
                    get: { manager.userSettings?.alarmSound ?? .softChime },
                    set: { manager.userSettings?.alarmSound = $0 }
                )) {
                    ForEach(AlarmSound.allCases) { sound in
                        Text(sound.rawValue).tag(sound)
                    }
                }
                
                Button("Test Notification") {
                    manager.notificationService.scheduleFeedReminder(lastFeedTime: Date().addingTimeInterval(-10000), intervalMinutes: 1)
                }
            }
            
            Section(header: Text("Babies")) {
                if let baby = manager.currentBaby {
                    NavigationLink(destination: BabyProfileView(baby: baby)) {
                        Text(baby.name)
                    }
                }
                Button("Add Baby") {
                    // Add baby logic
                }
            }
        }
        .navigationTitle("Settings")
    }
}
