import Foundation

public enum ActivityLevel: String, Codable, CaseIterable {
    case rest = "rest"
    case light = "light"
    case moderate = "moderate"
    case vigorous = "vigorous"
    
    public var numericValue: Double {
        switch self {
        case .rest: return 0.0
        case .light: return 1.0
        case .moderate: return 2.0
        case .vigorous: return 3.0
        }
    }
}

public struct SymptomEntry: Codable, Equatable {
    public var lightheadedness: Int // 0-10
    public var tachycardiaCount: Int
    public var tachycardiaSeverity: Int // 0-10
    public var fatigue: Int // 0-10
    public var brainFog: Int // 0-10
    public var nausea: Int // 0-10
    public var syncopeExperienced: Bool
    public var syncopeCount: Int
    
    public init(
        lightheadedness: Int = 0,
        tachycardiaCount: Int = 0,
        tachycardiaSeverity: Int = 0,
        fatigue: Int = 0,
        brainFog: Int = 0,
        nausea: Int = 0,
        syncopeExperienced: Bool = false,
        syncopeCount: Int = 0
    ) {
        self.lightheadedness = max(0, min(10, lightheadedness))
        self.tachycardiaCount = max(0, tachycardiaCount)
        self.tachycardiaSeverity = max(0, min(10, tachycardiaSeverity))
        self.fatigue = max(0, min(10, fatigue))
        self.brainFog = max(0, min(10, brainFog))
        self.nausea = max(0, min(10, nausea))
        self.syncopeExperienced = syncopeExperienced
        self.syncopeCount = max(0, syncopeCount)
    }
}

public struct TriggerCandidate: Codable, Equatable {
    public var foodNotes: String?
    public var sleepHours: Double?
    public var hydrationOunces: Double?
    public var standingTimeMinutes: Int?
    public var medicationTakenOnTime: Bool?
    public var menstrualCycleDay: Int?
    public var weatherBarometricPressure: Double?
    public var activityLevel: ActivityLevel?
    
    public init(
        foodNotes: String? = nil,
        sleepHours: Double? = nil,
        hydrationOunces: Double? = nil,
        standingTimeMinutes: Int? = nil,
        medicationTakenOnTime: Bool? = nil,
        menstrualCycleDay: Int? = nil,
        weatherBarometricPressure: Double? = nil,
        activityLevel: ActivityLevel? = nil
    ) {
        self.foodNotes = foodNotes
        self.sleepHours = sleepHours
        self.hydrationOunces = hydrationOunces
        self.standingTimeMinutes = standingTimeMinutes
        self.medicationTakenOnTime = medicationTakenOnTime
        self.menstrualCycleDay = menstrualCycleDay
        self.weatherBarometricPressure = weatherBarometricPressure
        self.activityLevel = activityLevel
    }
}

public struct HealthKitPull: Codable, Equatable {
    public var heartRateAverage: Double?
    public var heartRateMin: Double?
    public var heartRateMax: Double?
    public var heartRateVariabilityAverage: Double?
    public var sleepDuration: Double?
    public var stepCount: Int?
    
    public init(
        heartRateAverage: Double? = nil,
        heartRateMin: Double? = nil,
        heartRateMax: Double? = nil,
        heartRateVariabilityAverage: Double? = nil,
        sleepDuration: Double? = nil,
        stepCount: Int? = nil
    ) {
        self.heartRateAverage = heartRateAverage
        self.heartRateMin = heartRateMin
        self.heartRateMax = heartRateMax
        self.heartRateVariabilityAverage = heartRateVariabilityAverage
        self.sleepDuration = sleepDuration
        self.stepCount = stepCount
    }
}

public struct DailyLog: Codable, Identifiable, Equatable {
    public var id: UUID
    public var date: Date
    public var symptoms: SymptomEntry
    public var notes: String?
    public var triggerCandidate: TriggerCandidate
    public var healthKitPull: HealthKitPull
    
    public init(
        id: UUID = UUID(),
        date: Date,
        symptoms: SymptomEntry = SymptomEntry(),
        notes: String? = nil,
        triggerCandidate: TriggerCandidate = TriggerCandidate(),
        healthKitPull: HealthKitPull = HealthKitPull()
    ) {
        self.id = id
        self.date = date
        self.symptoms = symptoms
        self.notes = notes
        self.triggerCandidate = triggerCandidate
        self.healthKitPull = healthKitPull
    }
}
