import SwiftUI
import SwiftData

@main
struct NurtureApp: App {
    @StateObject private var manager = NurtureManager()
    
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                Baby.self,
                FeedEvent.self,
                DiaperEvent.self,
                UserSettings.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(manager)
        }
        .modelContainer(container)
    }
}
