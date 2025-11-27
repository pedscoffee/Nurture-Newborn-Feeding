import ActivityKit
import Foundation

struct NurtureWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic state updated during activity
        var nextFeedDate: Date
        var isOverdue: Bool
    }

    // Fixed non-changing properties
    var babyName: String
}
