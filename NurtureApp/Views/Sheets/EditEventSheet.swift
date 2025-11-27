import SwiftUI

struct EditEventSheet: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var event: FeedEvent
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Time")) {
                    DatePicker("Time", selection: $event.timestamp)
                }
                
                Section(header: Text("Details")) {
                    Picker("Type", selection: $event.type) {
                        ForEach(FeedType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if event.type == .formula {
                        TextField("Formula Brand", text: Binding(
                            get: { event.formulaType ?? "" },
                            set: { event.formulaType = $0 }
                        ))
                    }
                    
                    TextField("Amount (ml)", value: $event.amountML, format: .number)
                        .keyboardType(.numberPad)
                    
                    TextField("Duration (min)", value: $event.durationMinutes, format: .number)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: Binding(
                        get: { event.notes ?? "" },
                        set: { event.notes = $0 }
                    ))
                }
            }
            .navigationTitle("Edit Feed")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
