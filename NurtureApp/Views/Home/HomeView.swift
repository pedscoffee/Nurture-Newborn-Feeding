import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject var manager: NurtureManager
    @Environment(\.colorScheme) var colorScheme
    @State private var showEditSheet = false
    @State private var selectedEvent: FeedEvent? // Or generic Event protocol if we had one
    
    var body: some View {
        ZStack {
            // Background
            Theme.background(for: manager.userSettings?.theme ?? .dark, colorScheme: colorScheme)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text(Date(), style: .time)
                        .font(.headline)
                        .foregroundColor(Theme.textSecondary(for: manager.userSettings?.theme ?? .dark, colorScheme: colorScheme))
                    Spacer()
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(Theme.textPrimary(for: manager.userSettings?.theme ?? .dark, colorScheme: colorScheme))
                    }
                }
                .padding(.horizontal)
                
                // Timer Toggle
                Picker("Mode", selection: Binding(
                    get: { manager.userSettings?.viewMode ?? .countdown },
                    set: { manager.userSettings?.viewMode = $0 }
                )) {
                    ForEach([TimerViewMode.countdown, .stopwatch]) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Main Timer
                TimerDisplay(
                    timerService: manager.timerService,
                    viewMode: manager.userSettings?.viewMode ?? .countdown
                )
                
                // Encouragement
                Text("You're doing a great job!")
                    .font(.headline)
                    .foregroundColor(Theme.accent(for: manager.userSettings?.theme ?? .dark, colorScheme: colorScheme))
                    .padding(.top, 8)
                
                Spacer()
                
                // Actions
                ActionButtons()
                    .padding(.horizontal)
                
                Spacer()
                
                // Recent Activity Preview
                VStack(alignment: .leading) {
                    HStack {
                        Text("Recent Activity")
                            .font(.headline)
                            .foregroundColor(Theme.textPrimary(for: manager.userSettings?.theme ?? .dark, colorScheme: colorScheme))
                        Spacer()
                        NavigationLink(destination: HistoryView()) {
                            Text("History >")
                                .foregroundColor(Theme.accent(for: manager.userSettings?.theme ?? .dark, colorScheme: colorScheme))
                        }
                    }
                    .padding(.horizontal)
                    
                    if let baby = manager.currentBaby {
                        List {
                            ForEach(baby.feedEvents.sorted(by: { $0.timestamp > $1.timestamp }).prefix(3)) { event in
                                HStack {
                                    Text(event.type.icon)
                                    VStack(alignment: .leading) {
                                        Text(event.timestamp, style: .time)
                                            .font(.headline)
                                        Text("\(event.type.rawValue) • \(event.durationMinutes ?? 0)m")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Button("Edit") {
                                        // specific logic to open edit sheet
                                    }
                                    .font(.caption)
                                }
                                .listRowBackground(Theme.surface(for: manager.userSettings?.theme ?? .dark, colorScheme: colorScheme))
                            }
                        }
                        .listStyle(.plain)
                        .frame(height: 200)
                    }
                }
            }
            .padding(.top)
        }
        .navigationBarHidden(true)
    }
}
