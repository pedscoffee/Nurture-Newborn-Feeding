import Foundation
import SwiftData
import UIKit // For UIDevice

@Model
final class DiaperEvent {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var type: DiaperType
    var notes: String?
    var createdAt: Date
    var modifiedAt: Date
    var createdByDeviceID: String?
    
    // Relationship
    var baby: Baby?
    
    // CloudKit sync metadata
    var cloudKitRecordID: String?
    var needsSync: Bool = false
    
    init(
        timestamp: Date = Date(),
        type: DiaperType,
        baby: Baby?,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.timestamp = timestamp
        self.type = type
        self.baby = baby
        self.notes = notes
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.createdByDeviceID = UIDevice.current.identifierForVendor?.uuidString
    }
}
