import Foundation
import SwiftData
import UIKit // For UIDevice

@Model
final class FeedEvent {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var type: FeedType
    var durationMinutes: Int?
    var amountML: Int?
    var formulaType: String?
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
        type: FeedType,
        baby: Baby?,
        durationMinutes: Int? = nil,
        amountML: Int? = nil,
        formulaType: String? = nil,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.timestamp = timestamp
        self.type = type
        self.baby = baby
        self.durationMinutes = durationMinutes
        self.amountML = amountML
        self.formulaType = formulaType
        self.notes = notes
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.createdByDeviceID = UIDevice.current.identifierForVendor?.uuidString
    }
}
