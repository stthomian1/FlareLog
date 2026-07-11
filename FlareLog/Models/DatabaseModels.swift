import Foundation
import SwiftData
import FlareLogCore

@Model
public final class SDDailyLog {
    @Attribute(.unique) public var id: UUID
    public var date: Date
    public var notes: String?
    
    // Symptoms
    public var symptomLightheadedness: Int
    public var symptomTachycardiaCount: Int
    public var symptomTachycardiaSeverity: Int
    public var symptomFatigue: Int
    public var symptomBrainFog: Int
    public var symptomNausea: Int
    public var symptomSyncopeExperienced: Bool
    public var symptomSyncopeCount: Int
    
    // Trigger Candidates
    public var triggerFoodNotes: String?
    public var triggerSleepHours: Double?
    public var triggerHydrationLiters: Double?
    public var triggerStandingTimeMinutes: Int?
    public var triggerMedicationTakenOnTime: Bool?
    public var triggerMenstrualCycleDay: Int?
    public var triggerWeatherBarometricPressure: Double?
    public var triggerActivityLevelRaw: String?
    
    // HealthKit Pull
    public var hkHeartRateAverage: Double?
    public var hkHeartRateMin: Double?
    public var hkHeartRateMax: Double?
    public var hkHRVAverage: Double?
    public var hkSleepDuration: Double?
    public var hkStepCount: Int?
    
    public init(
        id: UUID = UUID(),
        date: Date,
        notes: String? = nil,
        symptoms: SymptomEntry = SymptomEntry(),
        triggerCandidate: TriggerCandidate = TriggerCandidate(),
        healthKitPull: HealthKitPull = HealthKitPull()
    ) {
        self.id = id
        // Store log at day boundary
        self.date = Calendar.current.startOfDay(for: date)
        self.notes = notes
        
        // Symptoms
        self.symptomLightheadedness = symptoms.lightheadedness
        self.symptomTachycardiaCount = symptoms.tachycardiaCount
        self.symptomTachycardiaSeverity = symptoms.tachycardiaSeverity
        self.symptomFatigue = symptoms.fatigue
        self.symptomBrainFog = symptoms.brainFog
        self.symptomNausea = symptoms.nausea
        self.symptomSyncopeExperienced = symptoms.syncopeExperienced
        self.symptomSyncopeCount = symptoms.syncopeCount
        
        // Triggers
        self.triggerFoodNotes = triggerCandidate.foodNotes
        self.triggerSleepHours = triggerCandidate.sleepHours
        self.triggerHydrationLiters = triggerCandidate.hydrationLiters
        self.triggerStandingTimeMinutes = triggerCandidate.standingTimeMinutes
        self.triggerMedicationTakenOnTime = triggerCandidate.medicationTakenOnTime
        self.triggerMenstrualCycleDay = triggerCandidate.menstrualCycleDay
        self.triggerWeatherBarometricPressure = triggerCandidate.weatherBarometricPressure
        self.triggerActivityLevelRaw = triggerCandidate.activityLevel?.rawValue
        
        // HealthKit
        self.hkHeartRateAverage = healthKitPull.heartRateAverage
        self.hkHeartRateMin = healthKitPull.heartRateMin
        self.hkHeartRateMax = healthKitPull.heartRateMax
        self.hkHRVAverage = healthKitPull.heartRateVariabilityAverage
        self.hkSleepDuration = healthKitPull.sleepDuration
        self.hkStepCount = healthKitPull.stepCount
    }
    
    public func toDomain() -> DailyLog {
        let symptoms = SymptomEntry(
            lightheadedness: symptomLightheadedness,
            tachycardiaCount: symptomTachycardiaCount,
            tachycardiaSeverity: symptomTachycardiaSeverity,
            fatigue: symptomFatigue,
            brainFog: symptomBrainFog,
            nausea: symptomNausea,
            syncopeExperienced: symptomSyncopeExperienced,
            syncopeCount: symptomSyncopeCount
        )
        
        let activityLevel = triggerActivityLevelRaw.flatMap(ActivityLevel.init(rawValue:))
        let trigger = TriggerCandidate(
            foodNotes: triggerFoodNotes,
            sleepHours: triggerSleepHours,
            hydrationLiters: triggerHydrationLiters,
            standingTimeMinutes: triggerStandingTimeMinutes,
            medicationTakenOnTime: triggerMedicationTakenOnTime,
            menstrualCycleDay: triggerMenstrualCycleDay,
            weatherBarometricPressure: triggerWeatherBarometricPressure,
            activityLevel: activityLevel
        )
        
        let hk = HealthKitPull(
            heartRateAverage: hkHeartRateAverage,
            heartRateMin: hkHeartRateMin,
            heartRateMax: hkHeartRateMax,
            heartRateVariabilityAverage: hkHRVAverage,
            sleepDuration: hkSleepDuration,
            stepCount: hkStepCount
        )
        
        return DailyLog(
            id: id,
            date: date,
            symptoms: symptoms,
            notes: notes,
            triggerCandidate: trigger,
            healthKitPull: hk
        )
    }
    
    public func update(with log: DailyLog) {
        self.date = Calendar.current.startOfDay(for: log.date)
        self.notes = log.notes
        
        self.symptomLightheadedness = log.symptoms.lightheadedness
        self.symptomTachycardiaCount = log.symptoms.tachycardiaCount
        self.symptomTachycardiaSeverity = log.symptoms.tachycardiaSeverity
        self.symptomFatigue = log.symptoms.fatigue
        self.symptomBrainFog = log.symptoms.brainFog
        self.symptomNausea = log.symptoms.nausea
        self.symptomSyncopeExperienced = log.symptoms.syncopeExperienced
        self.symptomSyncopeCount = log.symptoms.syncopeCount
        
        self.triggerFoodNotes = log.triggerCandidate.foodNotes
        self.triggerSleepHours = log.triggerCandidate.sleepHours
        self.triggerHydrationLiters = log.triggerCandidate.hydrationLiters
        self.triggerStandingTimeMinutes = log.triggerCandidate.standingTimeMinutes
        self.triggerMedicationTakenOnTime = log.triggerCandidate.medicationTakenOnTime
        self.triggerMenstrualCycleDay = log.triggerCandidate.menstrualCycleDay
        self.triggerWeatherBarometricPressure = log.triggerCandidate.weatherBarometricPressure
        self.triggerActivityLevelRaw = log.triggerCandidate.activityLevel?.rawValue
        
        self.hkHeartRateAverage = log.healthKitPull.heartRateAverage
        self.hkHeartRateMin = log.healthKitPull.heartRateMin
        self.hkHeartRateMax = log.healthKitPull.heartRateMax
        self.hkHRVAverage = log.healthKitPull.heartRateVariabilityAverage
        self.hkSleepDuration = log.healthKitPull.sleepDuration
        self.hkStepCount = log.healthKitPull.stepCount
    }
}
