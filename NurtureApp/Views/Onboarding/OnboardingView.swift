import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var manager: NurtureManager
    @State private var babyName = ""
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Welcome to Nurture")
                .font(.largeTitle.bold())
            
            Text("A calming way to track your newborn's feeding.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            TextField("Baby's Name", text: $babyName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Get Started") {
                if !babyName.isEmpty {
                    let baby = Baby(name: babyName)
                    manager.modelContext?.insert(baby)
                    manager.currentBaby = baby
                    manager.userSettings?.hasCompletedOnboarding = true
                }
            }
            .disabled(babyName.isEmpty)
            .padding()
            .background(babyName.isEmpty ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}
