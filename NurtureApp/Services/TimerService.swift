import Foundation
import SwiftUI
import Combine

class TimerService: ObservableObject {
    @Published var timeRemaining: TimeInterval = 0
    @Published var timeElapsed: TimeInterval = 0
    @Published var isOverdue: Bool = false
    
    private var timer: Timer?
    private var lastFeedTime: Date?
    private var feedInterval: TimeInterval = 0
    
    init() {
        // Start a timer to update UI every second
        startTimer()
    }
    
    func updateState(lastFeed: Date?, intervalMinutes: Int) {
        self.lastFeedTime = lastFeed
        self.feedInterval = TimeInterval(intervalMinutes * 60)
        calculateTimes()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.calculateTimes()
        }
    }
    
    private func calculateTimes() {
        guard let lastFeed = lastFeedTime else {
            timeRemaining = 0
            timeElapsed = 0
            isOverdue = false
            return
        }
        
        let now = Date()
        let nextFeedTime = lastFeed.addingTimeInterval(feedInterval)
        
        // Stopwatch mode (Time since last feed)
        timeElapsed = now.timeIntervalSince(lastFeed)
        
        // Countdown mode (Time until next feed)
        let remaining = nextFeedTime.timeIntervalSince(now)
        
        if remaining <= 0 {
            timeRemaining = 0
            isOverdue = true
        } else {
            timeRemaining = remaining
            isOverdue = false
        }
    }
    
    func formattedTime(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
