import SwiftUI
import SwiftData
import FlareLogCore

public struct DailyLogView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var healthKitService: HealthKitService
    
    @Binding public var isPresented: Bool
    public var editingLog: DailyLog?
    
    // --- STATED FIELDS ---
    @State private var logDate: Date = Date()
    @State private var notes: String = ""
    
    // Symptoms
    @State private var lightheadedness: Double = 0.0
    @State private var tachycardiaCount: Int = 0
    @State private var tachycardiaSeverity: Double = 0.0
    @State private var fatigue: Double = 0.0
    @State private var brainFog: Double = 0.0
    @State private var nausea: Double = 0.0
    @State private var syncopeExperienced: Bool = false
    @State private var syncopeCount: Int = 0
    
    // Triggers
    @State private var foodNotes: String = ""
    @State private var sleepHours: Double = 7.0
    @State private var hydrationOunces: Double = 64.0
    @State private var standingTimeMinutes: Int = 20
    @State private var medicationTakenOnTime: Bool = true
    @State private var menstrualCycleDay: Int = 1
    @State private var enableMenstrualCycle: Bool = false
    @State private var barometricPressure: String = ""
    @State private var activityLevel: ActivityLevel = .light
    
    @State private var showHelpSheet: Bool = false
    
    // HealthKit Loaded metrics
    @State private var hkAverageHR: Double? = nil
    @State private var hkMinHR: Double? = nil
    @State private var hkMaxHR: Double? = nil
    @State private var hkHRV: Double? = nil
    @State private var hkSleep: Double? = nil
    @State private var hkSteps: Int? = nil
    
    @State private var isSyncingHK: Bool = false
    @State private var hkSyncComplete: Bool = false
    
    public init(isPresented: Binding<Bool>, editingLog: DailyLog? = nil) {
        self._isPresented = isPresented
        self.editingLog = editingLog
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.06, green: 0.09, blue: 0.16)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Header info
                        HStack {
                            DatePicker("Journal Date", selection: $logDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .tint(.teal)
                            
                            Spacer()
                            
                            // HealthKit Sync Button
                            Button(action: syncWithHealthKit) {
                                HStack(spacing: 6) {
                                    if isSyncingHK {
                                        ProgressView()
                                            .tint(.teal)
                                    } else {
                                        Image(systemName: hkSyncComplete ? "checkmark.circle.fill" : "heart.text.square.fill")
                                            .foregroundColor(hkSyncComplete ? .green : .teal)
                                    }
                                    Text(hkSyncComplete ? "Synced" : "Sync Health")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(hkSyncComplete ? .green : .white)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.04))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(hkSyncComplete ? Color.green.opacity(0.4) : Color.teal.opacity(0.4), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        
                        // HealthKit values display if synced
                        if hkSyncComplete || hkAverageHR != nil {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Passive HealthKit Data")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.teal)
                                
                                HStack(spacing: 12) {
                                    if let steps = hkSteps {
                                        Label("\(steps) steps", systemImage: "figure.walk")
                                    }
                                    if let hr = hkAverageHR {
                                        Label("\(Int(hr)) bpm avg", systemImage: "heart.fill")
                                    }
                                    if let hrv = hkHRV {
                                        Label("\(Int(hrv))ms HRV", systemImage: "waveform.path.ecg")
                                    }
                                    if let sl = hkSleep {
                                        Label("\(String(format: "%.1f", sl))h sleep", systemImage: "bed.double.fill")
                                    }
                                }
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.all, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.teal.opacity(0.06))
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                        }
                        
                        // --- SECTION 1: SYMPTOMS (0-10 severity) ---
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("How bad are your symptoms? (0 to 10)")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                                Button(action: { showHelpSheet = true }) {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 16))
                                        .foregroundColor(.teal)
                                }
                            }
                            
                            // Lightheadedness slider
                            SliderRow(title: "Dizziness / Lightheadedness", value: $lightheadedness, maxVal: 10, icon: "brain")
                            
                            // Tachycardia episodes
                            VStack(spacing: 8) {
                                HStack {
                                    Label("Racing Heart Episodes (Tachycardia)", systemImage: "heart.fill")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.9))
                                    Spacer()
                                    Stepper("\(tachycardiaCount) times", value: $tachycardiaCount, in: 0...50)
                                        .font(.system(size: 13, weight: .bold))
                                }
                                
                                if tachycardiaCount > 0 {
                                    SliderRow(title: "Racing Heart Severity", value: $tachycardiaSeverity, maxVal: 10, icon: "heart.text.square")
                                        .transition(.slide)
                                }
                            }
                            
                            // Fatigue slider
                            SliderRow(title: "Fatigue (Extreme Tiredness)", value: $fatigue, maxVal: 10, icon: "battery.50")
                            
                            // Brain fog slider
                            SliderRow(title: "Brain Fog (Fuzzy Thinking)", value: $brainFog, maxVal: 10, icon: "cloud.drizzle")
                            
                            // Nausea slider
                            SliderRow(title: "Nausea (Sick to Stomach)", value: $nausea, maxVal: 10, icon: "thermometer")
                            
                            // Syncope / Near Syncope experienced
                            VStack(spacing: 8) {
                                Toggle(isOn: $syncopeExperienced.animation()) {
                                    Label("Fainting / Passing Out (Syncope)", systemImage: "sparkles.tv")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                .toggleStyle(SwitchToggleStyle(tint: .red))
                                
                                if syncopeExperienced {
                                    HStack {
                                        Text("Fainting or near-fainting times")
                                            .font(.system(size: 13))
                                            .foregroundColor(.white.opacity(0.7))
                                        Spacer()
                                        Stepper("\(syncopeCount) times", value: $syncopeCount, in: 1...20)
                                            .font(.system(size: 13, weight: .bold))
                                    }
                                    .transition(.slide)
                                }
                            }
                        }
                        .padding(.all, 16)
                        .background(Color(red: 0.12, green: 0.17, blue: 0.28).opacity(0.6))
                        .cornerRadius(16)
                        .padding(.horizontal, 16)
                        
                        // --- SECTION 2: DAILY HABITS / TRIGGERS ---
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Daily Habits & Triggers (What you did)")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                                Button(action: { showHelpSheet = true }) {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 16))
                                        .foregroundColor(.teal)
                                }
                            }
                            
                            // Sleep duration stepper
                            HStack {
                                Label("Sleep Time", systemImage: "bed.double")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                                Spacer()
                                Stepper("\(String(format: "%.1f", sleepHours)) h", value: $sleepHours, in: 0...24, step: 0.5)
                                    .font(.system(size: 13, weight: .bold))
                            }
                            
                            // Hydration stepper
                            HStack {
                                Label("Water Intake", systemImage: "drop")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                                Spacer()
                                Stepper("\(Int(hydrationOunces)) oz", value: $hydrationOunces, in: 0...300, step: 8)
                                    .font(.system(size: 13, weight: .bold))
                            }
                            
                            // Standing time minutes stepper
                            HStack {
                                Label("Time Spent Standing", systemImage: "clock")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                                Spacer()
                                Stepper("\(standingTimeMinutes) min", value: $standingTimeMinutes, in: 0...720, step: 5)
                                    .font(.system(size: 13, weight: .bold))
                            }
                            
                            // Medication on-time toggle
                            Toggle(isOn: $medicationTakenOnTime) {
                                Label("Meds Taken On Time", systemImage: "pills")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .teal))
                            
                            // Activity Level picker
                            VStack(alignment: .leading, spacing: 8) {
                                Label("How active were you?", systemImage: "figure.run")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                                Picker("Activity Level", selection: $activityLevel) {
                                    ForEach(ActivityLevel.allCases, id: \.self) { level in
                                        Text(level.rawValue.capitalized).tag(level)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            
                            // Menstrual cycle day (Optional)
                            VStack(alignment: .leading, spacing: 8) {
                                Toggle(isOn: $enableMenstrualCycle.animation()) {
                                    Label("Track Period Cycle Day", systemImage: "calendar.day.timeline.left")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                .toggleStyle(SwitchToggleStyle(tint: .teal))
                                
                                if enableMenstrualCycle {
                                    HStack {
                                        Text("Period Cycle Day")
                                            .font(.system(size: 13))
                                            .foregroundColor(.white.opacity(0.7))
                                        Spacer()
                                        Stepper("Day \(menstrualCycleDay)", value: $menstrualCycleDay, in: 1...40)
                                            .font(.system(size: 13, weight: .bold))
                                    }
                                }
                            }
                            
                            // Barometric Pressure (Optional text field)
                            HStack {
                                Label("Barometric Pressure (Air Pressure)", systemImage: "barometer")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                                Spacer()
                                TextField("1013", text: $barometricPressure)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .font(.system(size: 14, weight: .bold))
                                    .frame(width: 80)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.black.opacity(0.2))
                                    .cornerRadius(6)
                                Text("hPa")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            
                            // Food Notes text field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Food & Drink Notes (like high salt, lots of carbs)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.6))
                                TextField("Chips, salty foods, heavy lunch, etc.", text: $foodNotes)
                                    .font(.system(size: 14))
                                    .padding(.all, 10)
                                    .background(Color.black.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.all, 16)
                        .background(Color(red: 0.12, green: 0.17, blue: 0.28).opacity(0.6))
                        .cornerRadius(16)
                        .padding(.horizontal, 16)
                        
                        // --- SECTION 3: GENERAL NOTES ---
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Extra Notes")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            TextField("Write anything else here (like stress, school, weird weather)...", text: $notes, axis: .vertical)
                                .font(.system(size: 14))
                                .lineLimit(3...8)
                                .padding(.all, 12)
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .padding(.all, 16)
                        .background(Color(red: 0.12, green: 0.17, blue: 0.28).opacity(0.6))
                        .cornerRadius(16)
                        .padding(.horizontal, 16)
                        
                        // Save Button
                        Button(action: saveLog) {
                            Text("Save Journal Entry")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color.teal, Color(red: 0.0, green: 0.6, blue: 0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(14)
                                .shadow(color: .teal.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle(editingLog != nil ? "Edit Journal Entry" : "New Journal Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.white.opacity(0.6))
                }
            }
            .onAppear(perform: populateFromEditingLog)
            .sheet(isPresented: $showHelpSheet) {
                HelpSheetView()
            }
        }
    }
    
    private func populateFromEditingLog() {
        if let log = editingLog {
            logDate = log.date
            notes = log.notes ?? ""
            
            lightheadedness = Double(log.symptoms.lightheadedness)
            tachycardiaCount = log.symptoms.tachycardiaCount
            tachycardiaSeverity = Double(log.symptoms.tachycardiaSeverity)
            fatigue = Double(log.symptoms.fatigue)
            brainFog = Double(log.symptoms.brainFog)
            nausea = Double(log.symptoms.nausea)
            syncopeExperienced = log.symptoms.syncopeExperienced
            syncopeCount = log.symptoms.syncopeCount
            
            foodNotes = log.triggerCandidate.foodNotes ?? ""
            sleepHours = log.triggerCandidate.sleepHours ?? 7.0
            hydrationOunces = log.triggerCandidate.hydrationOunces ?? 64.0
            standingTimeMinutes = log.triggerCandidate.standingTimeMinutes ?? 20
            medicationTakenOnTime = log.triggerCandidate.medicationTakenOnTime ?? true
            if let cycle = log.triggerCandidate.menstrualCycleDay {
                menstrualCycleDay = cycle
                enableMenstrualCycle = true
            } else {
                enableMenstrualCycle = false
            }
            barometricPressure = log.triggerCandidate.weatherBarometricPressure.map { String($0) } ?? ""
            activityLevel = log.triggerCandidate.activityLevel ?? .light
            
            hkAverageHR = log.healthKitPull.heartRateAverage
            hkMinHR = log.healthKitPull.heartRateMin
            hkMaxHR = log.healthKitPull.heartRateMax
            hkHRV = log.healthKitPull.heartRateVariabilityAverage
            hkSleep = log.healthKitPull.sleepDuration
            hkSteps = log.healthKitPull.stepCount
        }
    }
    
    private func syncWithHealthKit() {
        isSyncingHK = true
        
        Task {
            // Check authorization or request it
            if !healthKitService.isAuthorized {
                await healthKitService.requestAuthorization()
            }
            
            let hkData = await healthKitService.fetchDailyData(for: logDate)
            
            // Populate
            hkAverageHR = hkData.heartRateAverage
            hkMinHR = hkData.heartRateMin
            hkMaxHR = hkData.heartRateMax
            hkHRV = hkData.heartRateVariabilityAverage
            hkSleep = hkData.sleepDuration
            hkSteps = hkData.stepCount
            
            // Autofill core form values if HealthKit returned genuine samples
            if let sleep = hkData.sleepDuration {
                sleepHours = sleep
            }
            
            isSyncingHK = false
            hkSyncComplete = true
        }
    }
    
    private func saveLog() {
        let symptoms = SymptomEntry(
            lightheadedness: Int(lightheadedness),
            tachycardiaCount: tachycardiaCount,
            tachycardiaSeverity: Int(tachycardiaSeverity),
            fatigue: Int(fatigue),
            brainFog: Int(brainFog),
            nausea: Int(nausea),
            syncopeExperienced: syncopeExperienced,
            syncopeCount: syncopeExperienced ? syncopeCount : 0
        )
        
        let triggers = TriggerCandidate(
            foodNotes: foodNotes.isEmpty ? nil : foodNotes,
            sleepHours: sleepHours,
            hydrationOunces: hydrationOunces,
            standingTimeMinutes: standingTimeMinutes,
            medicationTakenOnTime: medicationTakenOnTime,
            menstrualCycleDay: enableMenstrualCycle ? menstrualCycleDay : nil,
            weatherBarometricPressure: Double(barometricPressure),
            activityLevel: activityLevel
        )
        
        let hk = HealthKitPull(
            heartRateAverage: hkAverageHR,
            heartRateMin: hkMinHR,
            heartRateMax: hkMaxHR,
            heartRateVariabilityAverage: hkHRV,
            sleepDuration: hkSleep,
            stepCount: hkSteps
        )
        
        let startOfLogDate = Calendar.current.startOfDay(for: logDate)
        
        if let existingId = editingLog?.id {
            // Update
            let descriptor = FetchDescriptor<SDDailyLog>(predicate: #Predicate { $0.id == existingId })
            if let match = try? modelContext.fetch(descriptor).first {
                match.date = startOfLogDate
                match.notes = notes.isEmpty ? nil : notes
                match.update(with: DailyLog(id: existingId, date: startOfLogDate, symptoms: symptoms, notes: notes.isEmpty ? nil : notes, triggerCandidate: triggers, healthKitPull: hk))
            }
        } else {
            // Check duplicate date
            let descriptor = FetchDescriptor<SDDailyLog>(predicate: #Predicate { $0.date == startOfLogDate })
            if let duplicate = try? modelContext.fetch(descriptor).first {
                duplicate.notes = notes.isEmpty ? nil : notes
                duplicate.update(with: DailyLog(id: duplicate.id, date: startOfLogDate, symptoms: symptoms, notes: notes.isEmpty ? nil : notes, triggerCandidate: triggers, healthKitPull: hk))
            } else {
                // Insert new
                let newSDLog = SDDailyLog(
                    id: UUID(),
                    date: startOfLogDate,
                    notes: notes.isEmpty ? nil : notes,
                    symptoms: symptoms,
                    triggerCandidate: triggers,
                    healthKitPull: hk
                )
                modelContext.insert(newSDLog)
            }
        }
        
        try? modelContext.save()
        isPresented = false
    }
}

// Helper: Custom Row for Sliders
struct SliderRow: View {
    let title: String
    @Binding var value: Double
    let maxVal: Double
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                Text("\(Int(value))/\(Int(maxVal))")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.teal)
            }
            Slider(value: $value, in: 0...maxVal, step: 1.0)
                .accentColor(.teal)
        }
    }
}
