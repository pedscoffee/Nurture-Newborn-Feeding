import SwiftUI

struct ActionButtons: View {
    @EnvironmentObject var manager: NurtureManager
    
    var body: some View {
        VStack(spacing: 20) {
            // Start Feed Button
            Button(action: {
                manager.logFeed(type: manager.userSettings?.defaultFeedType ?? .both)
            }) {
                Text("Start Feed")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(20)
            }
            
            // Diaper Actions
            HStack(spacing: 16) {
                diaperButton(type: .wet)
                diaperButton(type: .dirty)
                diaperButton(type: .both)
            }
        }
    }
    
    private func diaperButton(type: DiaperType) -> some View {
        Button(action: {
            manager.logDiaper(type: type)
        }) {
            VStack {
                Text(type.icon)
                    .font(.title)
                Text(type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
