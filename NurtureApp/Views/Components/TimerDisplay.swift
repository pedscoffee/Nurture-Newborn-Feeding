import SwiftUI

struct TimerDisplay: View {
    @ObservedObject var timerService: TimerService
    let viewMode: TimerViewMode
    
    var body: some View {
        VStack(spacing: 8) {
            Text(timerService.formattedTime(
                viewMode == .countdown ? timerService.timeRemaining : timerService.timeElapsed
            ))
            .font(.system(size: 72, weight: .ultraLight, design: .default))
            .monospacedDigit()
            .foregroundColor(timerService.isOverdue && viewMode == .countdown ? .red : .primary)
            
            Text(viewMode == .countdown ? "Time until next feed" : "Time since last feed")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
