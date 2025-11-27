import SwiftUI
import SwiftData

struct HistoryView: View {
    @EnvironmentObject var manager: NurtureManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        List {
            Section(header: Text("Stats (24h)")) {
                HStack {
                    StatBox(label: "Feeds", value: "\(manager.feeds24h)")
                    StatBox(label: "Avg Interval", value: String(format: "%.1fh", manager.avgInterval / 3600))
                }
                HStack {
                    StatBox(label: "Wet", value: "\(manager.wet24h)")
                    StatBox(label: "Dirty", value: "\(manager.dirty24h)")
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            
            Section(header: Text("All Events")) {
                if let baby = manager.currentBaby {
                    ForEach(baby.feedEvents.sorted(by: { $0.timestamp > $1.timestamp })) { event in
                        HStack {
                            Text(event.type.icon)
                            VStack(alignment: .leading) {
                                Text(event.timestamp, format: .dateTime.month().day().hour().minute())
                                    .font(.headline)
                                Text(event.type.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteEvent)
                }
            }
        }
        .navigationTitle("History")
    }
    
    private func deleteEvent(at offsets: IndexSet) {
        // Deletion logic would go here, calling manager to remove from context
    }
}

struct StatBox: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack {
            Text(label).font(.caption).foregroundColor(.secondary)
            Text(value).font(.title2).bold()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
