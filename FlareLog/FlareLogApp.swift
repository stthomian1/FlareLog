import SwiftUI
import SwiftData
import FlareLogCore

@main
struct FlareLogApp: App {
    let container: ModelContainer
    
    @StateObject private var healthKitService = HealthKitService()
    @StateObject private var subscriptionManager = SubscriptionManager()
    
    @AppStorage("hasShownDisclaimer") private var hasShownDisclaimer: Bool = false
    @State private var showDisclaimerSheet: Bool = false
    
    public init() {
        do {
            let schema = Schema([SDDailyLog.self])
            // In iOS 17+, ModelConfiguration automatically uses NSFileProtectionComplete for user privacy
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not initialize SwiftData ModelContainer: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthKitService)
                .environmentObject(subscriptionManager)
                .preferredColorScheme(.dark) // Sleek, modern dark-themed aesthetics
                .onAppear {
                    if !hasShownDisclaimer {
                        showDisclaimerSheet = true
                    }
                }
                .sheet(isPresented: $showDisclaimerSheet) {
                    DisclaimerView(isPresented: $showDisclaimerSheet)
                        .interactiveDismissDisabled(true)
                }
        }
        .modelContainer(container)
    }
}
