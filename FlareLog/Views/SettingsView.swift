import SwiftUI
import SwiftData
import FlareLogCore

public struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var healthKitService: HealthKitService
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    @State private var showDisclaimer: Bool = false
    @State private var showPaywall: Bool = false
    @State private var showHelpGuide: Bool = false
    @State private var isGeneratingMockData: Bool = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.09, blue: 0.16)
                .ignoresSafeArea()
            
            Form {
                // Subscription & Accounts Section
                Section(header: Text("Subscription").foregroundColor(.teal)) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(subscriptionManager.isPremium ? "Premium Active" : "FlareLog Free")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            Text(subscriptionManager.isPremium ? "Full access to patterns & PDF export." : "Correlation engine is locked.")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        Spacer()
                        
                        if subscriptionManager.isPremium {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.teal)
                        } else {
                            Button("Upgrade") {
                                showPaywall = true
                            }
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.teal)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    Button("Restore Purchase") {
                        Task {
                            await subscriptionManager.restorePurchases()
                        }
                    }
                    .foregroundColor(.teal)
                    .font(.system(size: 14))
                }
                .listRowBackground(Color(red: 0.12, green: 0.17, blue: 0.28).opacity(0.6))
                
                // Help & Support Section
                Section(header: Text("Help & Support").foregroundColor(.teal)) {
                    Button(action: { showHelpGuide = true }) {
                        HStack {
                            Label("Help Guide & Definitions", systemImage: "questionmark.circle")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                }
                .listRowBackground(Color(red: 0.12, green: 0.17, blue: 0.28).opacity(0.6))
                
                // HealthKit Section
                Section(header: Text("Apple Health Sync").foregroundColor(.teal)) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Health Data Access")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white)
                            Text(healthKitService.isAuthorized ? "Active" : "Not connected")
                                .font(.system(size: 11))
                                .foregroundColor(healthKitService.isAuthorized ? .green : .white.opacity(0.4))
                        }
                        Spacer()
                        
                        Button(healthKitService.isAuthorized ? "Re-sync" : "Connect") {
                            Task {
                                await healthKitService.requestAuthorization()
                            }
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.teal)
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color(red: 0.12, green: 0.17, blue: 0.28).opacity(0.6))
                
                // Legal & Regulatory Framing Section
                Section(header: Text("Safety & Legal").foregroundColor(.teal)) {
                    Button(action: { showDisclaimer = true }) {
                        HStack {
                            Text("View Safety Warning")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("App Limits Warning")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                        Text("FlareLog is a daily journal to track how you feel. It doesn't diagnose, treat, or manage POTS or any other illness. It doesn't give medical orders, set activity limits, or change your meds. Use it only as a personal reference.")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.45))
                            .lineSpacing(2)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("🔒 100% Private & Local Data")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                        Text("Every single piece of information you enter into FlareLog remains completely private. All your logs are stored safely right on your own local device. None of your logs, habits, or data is stored in the cloud or sent to any server.")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.45))
                            .lineSpacing(2)
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color(red: 0.12, green: 0.17, blue: 0.28).opacity(0.6))
                
                // Developer / Testing Tools Section
                Section(header: Text("Developer Tools").foregroundColor(.orange)) {
                    Toggle("Mock Premium Status", isOn: Binding(
                        get: { subscriptionManager.isPremium },
                        set: { _ in subscriptionManager.togglePremiumDebug() }
                    ))
                    .tint(.orange)
                    .foregroundColor(.white)
                    
                    Button(action: {
                        isGeneratingMockData = true
                        generateSyntheticLogs()
                        isGeneratingMockData = false
                    }) {
                        HStack {
                            if isGeneratingMockData {
                                ProgressView()
                                    .tint(.orange)
                            } else {
                                Image(systemName: "square.stack.3d.up.fill")
                            }
                            Text("Generate 20 Days of Synthetic Logs")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.orange)
                    }
                    .disabled(isGeneratingMockData)
                    
                    Text("Unlock Premium features to test math patterns, charts, and PDF exports. The test data puts in patterns on purpose (like less sleep makes you more dizzy) to test the app.")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.4))
                }
                .listRowBackground(Color(red: 0.12, green: 0.17, blue: 0.28).opacity(0.6))
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showDisclaimer) {
            DisclaimerView(isPresented: $showDisclaimer)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(isPresented: $showPaywall)
        }
        .sheet(isPresented: $showHelpGuide) {
            HelpSheetView()
        }
    }
    
    private func generateSyntheticLogs() {
        // Generate 20 days of synthetic data
        for i in 0..<20 {
            let offsetDays = -i
            let date = Calendar.current.date(byAdding: .day, value: offsetDays, to: Date())!
            
            // Sleep ranges from 5.0 to 9.0 hours
            let sleep = 5.0 + Double(i % 5)
            
            // Plant strong negative correlation between sleepHours and lightheadedness severity
            let baseLight = Int(14.0 - sleep * 1.5)
            let noise = (i % 2 == 0) ? 1 : 0
            let lightheadedness = max(0, min(10, baseLight + noise))
            
            // Standing time: 10 to 50 min
            let standTime = 10 + (i % 5) * 10
            let tachyCount = max(0, (standTime - 10) / 10 + (i % 2))
            let tachySeverity = tachyCount > 0 ? max(1, min(10, tachyCount * 2 - noise)) : 0
            
            let symptoms = SymptomEntry(
                lightheadedness: lightheadedness,
                tachycardiaCount: tachyCount,
                tachycardiaSeverity: tachySeverity,
                fatigue: max(1, min(10, Int(8 - sleep / 2) + noise)),
                brainFog: max(1, min(10, Int(9 - sleep / 1.8))),
                nausea: (i % 4 == 0) ? 3 : 0,
                syncopeExperienced: (i == 5 || i == 12),
                syncopeCount: (i == 5 || i == 12) ? 1 : 0
            )
            
            let triggers = TriggerCandidate(
                foodNotes: i % 3 == 0 ? "High salt diet" : "Regular food",
                sleepHours: sleep,
                hydrationOunces: 32.0 + Double(i % 4) * 16.0,
                standingTimeMinutes: standTime,
                medicationTakenOnTime: i % 8 != 0,
                menstrualCycleDay: i % 28 + 1,
                weatherBarometricPressure: 1008.0 + Double(i % 10),
                activityLevel: i % 4 == 0 ? .rest : (i % 4 == 1 ? .light : (i % 4 == 2 ? .moderate : .vigorous))
            )
            
            let hk = HealthKitPull(
                heartRateAverage: 72.0 + Double(tachyCount * 5),
                heartRateMin: 55.0,
                heartRateMax: 110.0 + Double(tachyCount * 10),
                heartRateVariabilityAverage: 45.0 + sleep * 3.0,
                sleepDuration: sleep - 0.2,
                stepCount: 2000 + standTime * 150
            )
            
            let startOfLogDate = Calendar.current.startOfDay(for: date)
            
            // Check if log already exists for this date, overwrite to prevent duplicates
            let descriptor = FetchDescriptor<SDDailyLog>(predicate: #Predicate { $0.date == startOfLogDate })
            if let duplicate = try? modelContext.fetch(descriptor).first {
                duplicate.notes = "Synthetic log for testing day \(i + 1)"
                duplicate.update(with: DailyLog(id: duplicate.id, date: startOfLogDate, symptoms: symptoms, notes: duplicate.notes, triggerCandidate: triggers, healthKitPull: hk))
            } else {
                let newSDLog = SDDailyLog(
                    id: UUID(),
                    date: startOfLogDate,
                    notes: "Synthetic log for testing day \(i + 1)",
                    symptoms: symptoms,
                    triggerCandidate: triggers,
                    healthKitPull: hk
                )
                modelContext.insert(newSDLog)
            }
        }
        
        try? modelContext.save()
    }
}
