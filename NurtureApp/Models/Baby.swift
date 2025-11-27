import Foundation
import SwiftData

@Model
final class Baby {
    @Attribute(.unique) var id: UUID
    var name: String
    var birthDate: Date?
    var feedIntervalMinutes: Int
    var createdAt: Date
    var modifiedAt: Date
    
    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \FeedEvent.baby)
    var feedEvents: [FeedEvent] = []
    
    @Relationship(deleteRule: .cascade, inverse: \DiaperEvent.baby)
    var diaperEvents: [DiaperEvent] = []
    
    // CloudKit sync metadata
    var cloudKitRecordID: String?
    var cloudKitShareID: String?
    
    init(name: String, feedIntervalMinutes: Int = 150, birthDate: Date? = nil) {
        self.id = UUID()
        self.name = name
        self.birthDate = birthDate
        self.feedIntervalMinutes = feedIntervalMinutes
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
}
