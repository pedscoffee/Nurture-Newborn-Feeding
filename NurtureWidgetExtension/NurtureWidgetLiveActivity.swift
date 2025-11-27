import ActivityKit
import WidgetKit
import SwiftUI

struct NurtureWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NurtureWidgetAttributes.self) { context in
            // Lock Screen/Banner UI
            VStack {
                HStack {
                    Text("Next Feed")
                        .font(.headline)
                    Spacer()
                    if context.state.isOverdue {
                        Text("OVERDUE")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .clipShape(Capsule())
                    }
                }
                
                HStack(alignment: .bottom) {
                    Text(context.state.nextFeedDate, style: .timer)
                        .font(.system(size: 48, weight: .light))
                        .monospacedDigit()
                        .multilineTextAlignment(.center)
                    Spacer()
                    Text("Due \(context.state.nextFeedDate.formatted(date: .omitted, time: .shortened))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .activityBackgroundTint(Color(red: 0.12, green: 0.12, blue: 0.18)) // Dark theme bg
            .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Text("Next Feed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.nextFeedDate, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.nextFeedDate, style: .timer)
                        .font(.system(size: 40, weight: .light))
                        .monospacedDigit()
                        .foregroundColor(context.state.isOverdue ? .red : .white)
                        .frame(maxWidth: .infinity)
                }
            } compactLeading: {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
            } compactTrailing: {
                Text(context.state.nextFeedDate, style: .timer)
                    .monospacedDigit()
                    .frame(width: 50)
                    .foregroundColor(context.state.isOverdue ? .red : .white)
            } minimal: {
                Image(systemName: "clock")
                    .foregroundColor(context.state.isOverdue ? .red : .blue)
            }
            .widgetURL(URL(string: "nurture://home"))
            .keylineTint(Color.blue)
        }
    }
}
