import SwiftUI
import SwiftData
import FlareLogCore

public struct ContentView: View {
    @Query(sort: \SDDailyLog.date, order: .reverse) private var logs: [SDDailyLog]
    @State private var selectedTab: Int = 0
    @State private var showLogEditor: Bool = false
    @State private var editingLog: DailyLog? = nil
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard
            NavigationStack {
                DashboardView(showLogEditor: $showLogEditor, editingLog: $editingLog)
            }
            .tabItem {
                Label("Dashboard", systemImage: "square.grid.2x2.fill")
            }
            .tag(0)
            
            // Patterns
            NavigationStack {
                PatternsView()
            }
            .tabItem {
                Label("Patterns", systemImage: "chart.xyaxis.line")
            }
            .tag(1)
            
            // Settings
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(2)
        }
        .tint(.teal)
        .sheet(isPresented: $showLogEditor, onDismiss: { editingLog = nil }) {
            DailyLogView(isPresented: $showLogEditor, editingLog: editingLog)
        }
    }
}

// Subview: Dashboard list and metrics
struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SDDailyLog.date, order: .reverse) private var logs: [SDDailyLog]
    @Binding var showLogEditor: Bool
    @Binding var editingLog: DailyLog?
    
    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.09, blue: 0.16)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    VStack(alignment: .leading, spacing: 4) {
                        Text("FLARELOG")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.teal)
                        
                        Text("Symptom Journal")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Track wellness, observe patterns.")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // Quick Action: Log Today
                    Button(action: {
                        editingLog = nil
                        showLogEditor = true
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Log Symptoms & Habits")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Record today's status in under 60 seconds")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.teal)
                        }
                        .padding(.all, 18)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.12, green: 0.17, blue: 0.28), Color(red: 0.08, green: 0.12, blue: 0.22)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.teal.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 16)
                    .shadow(color: .teal.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // Main Statistics Quick Metrics Widget
                    if !logs.isEmpty {
                        QuickStatsWidget(logs: logs)
                            .padding(.horizontal, 16)
                    }
                    
                    // Recent Logs Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Journal History")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                        
                        if logs.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "note.text")
                                    .font(.system(size: 48))
                                    .foregroundColor(.white.opacity(0.2))
                                Text("No journal entries yet")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white.opacity(0.4))
                                Text("Enter your first daily log to start tracking your POTS symptoms.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.3))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                            .background(Color.white.opacity(0.02))
                            .cornerRadius(16)
                            .padding(.horizontal, 16)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(logs) { log in
                                    RecentLogCard(log: log) {
                                        editingLog = log.toDomain()
                                        showLogEditor = true
                                    } onDelete: {
                                        modelContext.delete(log)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
    }
}

// Subview: Recent log record details card
struct RecentLogCard: View {
    let log: SDDailyLog
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onEdit) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(formattedDate(log.date))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            onDelete()
                        }
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                            .foregroundColor(.red.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                }
                
                // Symptom Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if log.symptomLightheadedness > 0 {
                            ChipView(text: "Lighthead: \(log.symptomLightheadedness)", color: .cyan)
                        }
                        if log.symptomTachycardiaCount > 0 {
                            ChipView(text: "Tachy: \(log.symptomTachycardiaCount)x", color: .purple)
                        }
                        if log.symptomFatigue > 0 {
                            ChipView(text: "Fatigue: \(log.symptomFatigue)", color: .orange)
                        }
                        if log.symptomBrainFog > 0 {
                            ChipView(text: "Fog: \(log.symptomBrainFog)", color: .blue)
                        }
                        if log.symptomNausea > 0 {
                            ChipView(text: "Nausea: \(log.symptomNausea)", color: .pink)
                        }
                        if log.symptomSyncopeExperienced {
                            ChipView(text: "Syncope: \(log.symptomSyncopeCount)x", color: .red)
                        }
                        
                        // If no symptoms, display none
                        if log.symptomLightheadedness == 0 &&
                            log.symptomTachycardiaCount == 0 &&
                            log.symptomFatigue == 0 &&
                            log.symptomBrainFog == 0 &&
                            log.symptomNausea == 0 &&
                            !log.symptomSyncopeExperienced {
                            ChipView(text: "No symptoms logged", color: .secondary)
                        }
                    }
                }
                
                // Habit Summary Line
                HStack(spacing: 12) {
                    if let sl = log.triggerSleepHours {
                        Label("\(String(format: "%.1f", sl))h sleep", systemImage: "bed.double.fill")
                    }
                    if let hyd = log.triggerHydrationLiters {
                        Label("\(String(format: "%.1f", hyd))L hydration", systemImage: "drop.fill")
                    }
                    if let st = log.triggerStandingTimeMinutes {
                        Label("\(st)m stand", systemImage: "clock.fill")
                    }
                }
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
                
                // Notes if present
                if let notes = log.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                        .padding(.all, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .padding(.all, 14)
            .background(Color(red: 0.12, green: 0.17, blue: 0.28).opacity(0.8))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct ChipView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(color.opacity(0.5), lineWidth: 1)
            )
    }
}

// Widget showing basic averages
struct QuickStatsWidget: View {
    let logs: [SDDailyLog]
    
    var body: some View {
        HStack(spacing: 12) {
            StatMetricBox(
                title: "Logging Days",
                value: "\(logs.count)",
                icon: "calendar",
                color: .teal
            )
            StatMetricBox(
                title: "Avg Lighthead",
                value: String(format: "%.1f", avgLightheadedness),
                icon: "brain.head.profile",
                color: .cyan
            )
            StatMetricBox(
                title: "Avg Hydration",
                value: String(format: "%.1fL", avgHydration),
                icon: "drop.fill",
                color: .blue
            )
        }
    }
    
    private var avgLightheadedness: Double {
        let valid = logs.map { Double($0.symptomLightheadedness) }
        return valid.isEmpty ? 0.0 : valid.reduce(0.0, +) / Double(valid.count)
    }
    
    private var avgHydration: Double {
        let valid = logs.compactMap { $0.triggerHydrationLiters }
        return valid.isEmpty ? 0.0 : valid.reduce(0.0, +) / Double(valid.count)
    }
}

struct StatMetricBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.all, 12)
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.12, green: 0.17, blue: 0.28).opacity(0.6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.04), lineWidth: 1)
        )
    }
}
