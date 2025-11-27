import Foundation
import UserNotifications

class NotificationService: ObservableObject {
    
    init() {
        requestPermissions()
    }
    
    func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleFeedReminder(lastFeedTime: Date, intervalMinutes: Int) {
        // Cancel existing reminders
        cancelAllNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "Time to Feed!"
        content.body = "It's been \(Double(intervalMinutes)/60.0) hours since the last feed."
        content.sound = UNNotificationSound.default
        
        let nextFeedTime = lastFeedTime.addingTimeInterval(TimeInterval(intervalMinutes * 60))
        let timeInterval = nextFeedTime.timeIntervalSince(Date())
        
        // Only schedule if in the future
        if timeInterval > 0 {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            let request = UNNotificationRequest(identifier: "feed_reminder", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
