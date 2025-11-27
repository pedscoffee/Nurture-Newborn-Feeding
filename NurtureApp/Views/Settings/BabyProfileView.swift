import SwiftUI

struct BabyProfileView: View {
    @Bindable var baby: Baby
    
    var body: some View {
        Form {
            Section(header: Text("Details")) {
                TextField("Name", text: $baby.name)
                DatePicker("Birth Date", selection: Binding(
                    get: { baby.birthDate ?? Date() },
                    set: { baby.birthDate = $0 }
                ), displayedComponents: .date)
            }
            
            Section(header: Text("Feeding")) {
                Stepper("Interval: \(baby.feedIntervalMinutes) min", value: $baby.feedIntervalMinutes, step: 15)
            }
        }
        .navigationTitle("Edit Baby")
    }
}
