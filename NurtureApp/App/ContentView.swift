import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var manager: NurtureManager
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        Group {
            if manager.userSettings?.hasCompletedOnboarding == true {
                HomeView()
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            manager.setContext(modelContext)
        }
    }
}
