import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
class NurtureManager: ObservableObject {
    
    // Services
    let timerService: TimerService
    let audioService: AudioService
    let notificationService: NotificationService
    let syncEngine: SyncEngine
    let liveActivityService: LiveActivityService
    
    // Data Context
    var modelContext: ModelContext?
    
    // State
    @Published var currentBaby: Baby?
    @Published var userSettings: UserSettings?
    
    // Computed Stats
    @Published var feeds24h: Int = 0
    @Published var wet24h: Int = 0
    @Published var dirty24h: Int = 0
    @Published var avgInterval: TimeInterval = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        timerService: TimerService = TimerService(),
        audioService: AudioService = AudioService(),
        notificationService: NotificationService = NotificationService(),
        syncEngine: SyncEngine = SyncEngine(),
        liveActivityService: LiveActivityService = LiveActivityService()
    ) {
        self.timerService = timerService
        self.audioService = audioService
        self.notificationService = notificationService
        self.syncEngine = syncEngine
        self.liveActivityService = liveActivityService
        
        setupBindings()
    }
    
    func setContext(_ context: ModelContext) {
        self.modelContext = context
        fetchInitialData()
    }
    
    private func setupBindings() {
        // Listen to timer updates to trigger UI refreshes if needed
        timerService.$isOverdue
            .sink { [weak self] isOverdue in
                if isOverdue {
                    // Handle overdue state (e.g., ensure alarm plays if app is active)
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchInitialData() {
        guard let context = modelContext else { return }
        
        // Fetch Settings
        do {
            var descriptor = FetchDescriptor<UserSettings>()
            descriptor.fetchLimit = 1
            let settings = try context.fetch(descriptor)
            
            if let first = settings.first {
                self.userSettings = first
            } else {
                // Create default settings
                let newSettings = UserSettings()
                context.insert(newSettings)
                self.userSettings = newSettings
            }
        } catch {
            print("Failed to fetch settings: \(error)")
        }
        
        // Fetch Babies
        do {
            let descriptor = FetchDescriptor<Baby>(sortBy: [SortDescriptor(\.createdAt)])
            let babies = try context.fetch(descriptor)
            
            if let selectedID = userSettings?.selectedBabyID, let found = babies.first(where: { $0.id == selectedID }) {
                self.currentBaby = found
            } else {
                self.currentBaby = babies.first
            }
        } catch {
            print("Failed to fetch babies: \(error)")
        }
        
        refreshStats()
        updateTimerState()
    }
    
    // MARK: - Actions
    
    func logFeed(type: FeedType, duration: Int? = nil, amount: Int? = nil, formulaType: String? = nil, notes: String? = nil) {
        guard let context = modelContext, let baby = currentBaby else { return }
        
        let feed = FeedEvent(
            type: type,
            baby: baby,
            durationMinutes: duration,
            amountML: amount,
            formulaType: formulaType,
            notes: notes
        )
        
        context.insert(feed)
        
        // Update Baby's modified date
        baby.modifiedAt = Date()
        
        // Reset Timer & Notifications
        updateTimerState()
        scheduleNextNotification()
        
        // Update Live Activity
        // liveActivityService.startTimerActivity(...)
        
        refreshStats()
    }
    
    func logDiaper(type: DiaperType, notes: String? = nil) {
        guard let context = modelContext, let baby = currentBaby else { return }
        
        let diaper = DiaperEvent(
            type: type,
            baby: baby,
            notes: notes
        )
        
        context.insert(diaper)
        baby.modifiedAt = Date()
        
        refreshStats()
    }
    
    // MARK: - Helpers
    
    private func updateTimerState() {
        guard let baby = currentBaby else { return }
        
        // Find last feed
        let lastFeed = baby.feedEvents.sorted(by: { $0.timestamp > $1.timestamp }).first
        
        timerService.updateState(
            lastFeed: lastFeed?.timestamp,
            intervalMinutes: baby.feedIntervalMinutes
        )
    }
    
    private func scheduleNextNotification() {
        guard let baby = currentBaby else { return }
        let lastFeed = baby.feedEvents.sorted(by: { $0.timestamp > $1.timestamp }).first
        
        if let lastFeedTime = lastFeed?.timestamp {
            notificationService.scheduleFeedReminder(
                lastFeedTime: lastFeedTime,
                intervalMinutes: baby.feedIntervalMinutes
            )
        }
    }
    
    func refreshStats() {
        guard let baby = currentBaby else { return }
        
        let now = Date()
        let oneDayAgo = now.addingTimeInterval(-24 * 60 * 60)
        
        // Feeds 24h
        feeds24h = baby.feedEvents.filter { $0.timestamp > oneDayAgo }.count
        
        // Diapers 24h
        let recentDiapers = baby.diaperEvents.filter { $0.timestamp > oneDayAgo }
        wet24h = recentDiapers.filter { $0.type == .wet || $0.type == .both }.count
        dirty24h = recentDiapers.filter { $0.type == .dirty || $0.type == .both }.count
        
        // Avg Interval (Last 10 feeds)
        let sortedFeeds = baby.feedEvents.sorted(by: { $0.timestamp > $1.timestamp })
        if sortedFeeds.count > 1 {
            let count = min(sortedFeeds.count - 1, 10)
            var totalInterval: TimeInterval = 0
            
            for i in 0..<count {
                let diff = sortedFeeds[i].timestamp.timeIntervalSince(sortedFeeds[i+1].timestamp)
                totalInterval += diff
            }
            
            avgInterval = totalInterval / Double(count)
        } else {
            avgInterval = 0
        }
    }
}
