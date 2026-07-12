import Foundation

public struct TestableVariable: Identifiable, Equatable {
    public let id: String
    public let displayName: String
    public let unit: String
    public let extractor: (DailyLog) -> Double?
    public let lowString: String
    public let highString: String
    
    public init(id: String, displayName: String, unit: String, extractor: @escaping (DailyLog) -> Double?, lowString: String, highString: String) {
        self.id = id
        self.displayName = displayName
        self.unit = unit
        self.extractor = extractor
        self.lowString = lowString
        self.highString = highString
    }
    
    public static func == (lhs: TestableVariable, rhs: TestableVariable) -> Bool {
        return lhs.id == rhs.id
    }
}

public struct CorrelationResult: Identifiable, Equatable {
    public var id: String { "\(trigger.id)-\(symptom.id)" }
    public let trigger: TestableVariable
    public let symptom: TestableVariable
    public let r: Double
    public let pValue: Double
    public var adjustedPValue: Double
    public var isSignificant: Bool
    public let observationalSentence: String
    public let sampleSize: Int
    
    public init(trigger: TestableVariable, symptom: TestableVariable, r: Double, pValue: Double, adjustedPValue: Double, isSignificant: Bool, observationalSentence: String, sampleSize: Int) {
        self.trigger = trigger
        self.symptom = symptom
        self.r = r
        self.pValue = pValue
        self.adjustedPValue = adjustedPValue
        self.isSignificant = isSignificant
        self.observationalSentence = observationalSentence
        self.sampleSize = sampleSize
    }
}

public struct CorrelationEngine {
    
    public static let alpha: Double = 0.05
    public static let minimumDaysThreshold: Int = 14
    
    public static let triggers: [TestableVariable] = [
        TestableVariable(
            id: "sleepHours",
            displayName: "sleep time",
            unit: "hours",
            extractor: { $0.triggerCandidate.sleepHours },
            lowString: "you slept under",
            highString: "you slept over"
        ),
        TestableVariable(
            id: "hydration",
            displayName: "water intake",
            unit: "oz",
            extractor: { $0.triggerCandidate.hydrationOunces },
            lowString: "you drank under",
            highString: "you drank over"
        ),
        TestableVariable(
            id: "standingTime",
            displayName: "standing time",
            unit: "minutes",
            extractor: { $0.triggerCandidate.standingTimeMinutes.map(Double.init) },
            lowString: "you stood for under",
            highString: "you stood for over"
        ),
        TestableVariable(
            id: "medication",
            displayName: "taking meds on time",
            unit: "",
            extractor: { $0.triggerCandidate.medicationTakenOnTime.map { $0 ? 1.0 : 0.0 } },
            lowString: "you missed your meds",
            highString: "you took your meds on time"
        ),
        TestableVariable(
            id: "menstrualCycleDay",
            displayName: "period cycle day",
            unit: "day",
            extractor: { $0.triggerCandidate.menstrualCycleDay.map(Double.init) },
            lowString: "your period cycle day was under",
            highString: "your period cycle day was over"
        ),
        TestableVariable(
            id: "barometricPressure",
            displayName: "air pressure (barometer)",
            unit: "hPa",
            extractor: { $0.triggerCandidate.weatherBarometricPressure },
            lowString: "air pressure was under",
            highString: "air pressure was over"
        ),
        TestableVariable(
            id: "activityLevel",
            displayName: "activity level",
            unit: "",
            extractor: { $0.triggerCandidate.activityLevel?.numericValue },
            lowString: "you were mostly resting",
            highString: "you were super active"
        ),
        TestableVariable(
            id: "hkSleep",
            displayName: "HealthKit sleep time",
            unit: "hours",
            extractor: { $0.healthKitPull.sleepDuration },
            lowString: "Apple Health said you slept under",
            highString: "Apple Health said you slept over"
        ),
        TestableVariable(
            id: "hkSteps",
            displayName: "HealthKit steps",
            unit: "steps",
            extractor: { $0.healthKitPull.stepCount.map(Double.init) },
            lowString: "Apple Health steps were under",
            highString: "Apple Health steps were over"
        ),
        TestableVariable(
            id: "hkHR",
            displayName: "avg heart rate",
            unit: "bpm",
            extractor: { $0.healthKitPull.heartRateAverage },
            lowString: "your average heart rate was under",
            highString: "your average heart rate was over"
        ),
        TestableVariable(
            id: "hkHRV",
            displayName: "avg heart rate variability (HRV)",
            unit: "ms",
            extractor: { $0.healthKitPull.heartRateVariabilityAverage },
            lowString: "your HRV was under",
            highString: "your HRV was over"
        )
    ]
    
    public static let symptoms: [TestableVariable] = [
        TestableVariable(
            id: "lightheadedness",
            displayName: "dizziness",
            unit: "/10",
            extractor: { Double($0.symptoms.lightheadedness) },
            lowString: "",
            highString: ""
        ),
        TestableVariable(
            id: "tachycardiaSeverity",
            displayName: "racing heart severity",
            unit: "/10",
            extractor: { Double($0.symptoms.tachycardiaSeverity) },
            lowString: "",
            highString: ""
        ),
        TestableVariable(
            id: "tachycardiaCount",
            displayName: "racing heart episodes",
            unit: "episodes",
            extractor: { Double($0.symptoms.tachycardiaCount) },
            lowString: "",
            highString: ""
        ),
        TestableVariable(
            id: "fatigue",
            displayName: "tiredness",
            unit: "/10",
            extractor: { Double($0.symptoms.fatigue) },
            lowString: "",
            highString: ""
        ),
        TestableVariable(
            id: "brainFog",
            displayName: "brain fog",
            unit: "/10",
            extractor: { Double($0.symptoms.brainFog) },
            lowString: "",
            highString: ""
        ),
        TestableVariable(
            id: "nausea",
            displayName: "nausea",
            unit: "/10",
            extractor: { Double($0.symptoms.nausea) },
            lowString: "",
            highString: ""
        ),
        TestableVariable(
            id: "syncopeCount",
            displayName: "fainting episodes",
            unit: "episodes",
            extractor: { Double($0.symptoms.syncopeCount) },
            lowString: "",
            highString: ""
        )
    ]
    
    public static func analyze(logs: [DailyLog]) -> [CorrelationResult] {
        var rawResults: [CorrelationResult] = []
        
        for trigger in triggers {
            for symptom in symptoms {
                // Gather paired, non-nil data points
                let pairedPoints = logs.compactMap { log -> (Double, Double)? in
                    guard let x = trigger.extractor(log),
                          let y = symptom.extractor(log) else {
                        return nil
                    }
                    return (x, y)
                }
                
                // Only calculate if the threshold is met for this specific pair
                guard pairedPoints.count >= minimumDaysThreshold else {
                    continue
                }
                
                let (r, pValue) = calculatePearsonCorrelation(pairedPoints: pairedPoints)
                
                // Generate observational sentence
                let sentence = generateObservationalSentence(
                    trigger: trigger,
                    symptom: symptom,
                    r: r,
                    pairedPoints: pairedPoints
                )
                
                let result = CorrelationResult(
                    trigger: trigger,
                    symptom: symptom,
                    r: r,
                    pValue: pValue,
                    adjustedPValue: 1.0, // adjusted later
                    isSignificant: false, // adjusted later
                    observationalSentence: sentence,
                    sampleSize: pairedPoints.count
                )
                rawResults.append(result)
            }
        }
        
        // Apply Benjamini-Hochberg FDR correction
        guard !rawResults.isEmpty else { return [] }
        
        // Sort results by raw p-value ascending
        let sortedIndices = rawResults.indices.sorted { rawResults[$0].pValue < rawResults[$1].pValue }
        let M = rawResults.count
        
        var adjustedPValues = [Double](repeating: 1.0, count: M)
        var minFutureVal = Double.infinity
        
        for indexInSorted in stride(from: M - 1, through: 0, by: -1) {
            let originalIndex = sortedIndices[indexInSorted]
            let pValue = rawResults[originalIndex].pValue
            let rank = indexInSorted + 1
            let rawAdjusted = pValue * Double(M) / Double(rank)
            minFutureVal = min(minFutureVal, rawAdjusted)
            adjustedPValues[indexInSorted] = min(1.0, max(0.0, minFutureVal))
        }
        
        // Map back to rawResults and determine significance
        for sortedRank in 0..<M {
            let originalIndex = sortedIndices[sortedRank]
            let adjustedP = adjustedPValues[sortedRank]
            rawResults[originalIndex].adjustedPValue = adjustedP
            rawResults[originalIndex].isSignificant = adjustedP <= alpha
        }
        
        return rawResults
    }
    
    private static func calculatePearsonCorrelation(pairedPoints: [(Double, Double)]) -> (r: Double, pValue: Double) {
        let n = Double(pairedPoints.count)
        let sumX = pairedPoints.reduce(0.0) { $0 + $1.0 }
        let sumY = pairedPoints.reduce(0.0) { $0 + $1.1 }
        
        let meanX = sumX / n
        let meanY = sumY / n
        
        var num = 0.0
        var denX = 0.0
        var denY = 0.0
        
        for point in pairedPoints {
            let diffX = point.0 - meanX
            let diffY = point.1 - meanY
            num += diffX * diffY
            denX += diffX * diffX
            denY += diffY * diffY
        }
        
        if denX == 0.0 || denY == 0.0 {
            return (0.0, 1.0)
        }
        
        let r = num / sqrt(denX * denY)
        // Cap r to prevent NaN/Infinity in calculations
        let clampedR = max(-0.99999, min(0.99999, r))
        
        // Calculate t-statistic
        let df = n - 2.0
        let t = abs(clampedR) * sqrt(df / (1.0 - clampedR * clampedR))
        
        // Wallace approximation for Student's t cumulative distribution function:
        // Z = (t * (1 - 1/(4*df))) / sqrt(1 + t^2 / (2*df))
        let z = (t * (1.0 - 0.25 / df)) / sqrt(1.0 + (t * t) / (2.0 * df))
        
        // Two-tailed p-value
        let pValue = 1.0 - errorFunction(z / sqrt(2.0))
        
        return (r, pValue)
    }
    
    private static func errorFunction(_ x: Double) -> Double {
        let p = 0.3275911
        let a1 = 0.254829592
        let a2 = -0.284496736
        let a3 = 1.421413741
        let a4 = -1.453152027
        let a5 = 1.061405429
        
        let t = 1.0 / (1.0 + p * abs(x))
        let erfVal = 1.0 - ((((a5 * t + a4) * t + a3) * t + a2) * t + a1) * t * exp(-x * x)
        return x >= 0 ? erfVal : -erfVal
    }
    
    private static func generateObservationalSentence(
        trigger: TestableVariable,
        symptom: TestableVariable,
        r: Double,
        pairedPoints: [(Double, Double)]
    ) -> String {
        let xValues = pairedPoints.map { $0.0 }.sorted()
        let medianX = xValues[xValues.count / 2]
        
        let yValues = pairedPoints.map { $0.1 }.sorted()
        let medianY = yValues[yValues.count / 2]
        
        let targetGroup: [(Double, Double)]
        let conditionPhrase: String
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        let formattedMedianX = formatter.string(from: NSNumber(value: medianX)) ?? "\(medianX)"
        
        if trigger.id == "medication" {
            // Binary variable logic
            if r > 0 {
                targetGroup = pairedPoints.filter { $0.0 >= 0.5 }
                conditionPhrase = "you took your meds on time"
            } else {
                targetGroup = pairedPoints.filter { $0.0 < 0.5 }
                conditionPhrase = "you missed your meds"
            }
        } else {
            // Continuous/ordinal variables
            if r > 0 {
                // Positive correlation: higher trigger -> higher symptom
                targetGroup = pairedPoints.filter { $0.0 > medianX }
                if trigger.unit.isEmpty {
                    conditionPhrase = "\(trigger.highString) \(formattedMedianX)"
                } else {
                    conditionPhrase = "\(trigger.highString) \(formattedMedianX) \(trigger.unit)"
                }
            } else {
                // Negative correlation: lower trigger -> higher symptom (e.g. low sleep -> high symptoms)
                targetGroup = pairedPoints.filter { $0.0 <= medianX }
                if trigger.unit.isEmpty {
                    conditionPhrase = "\(trigger.lowString) \(formattedMedianX)"
                } else {
                    conditionPhrase = "\(trigger.lowString) \(formattedMedianX) \(trigger.unit)"
                }
            }
        }
        
        // Define baseline: if medianY is 0, we count entries where symptom > 0.
        // Otherwise, we count entries where symptom > medianY.
        let symptomThreshold = medianY > 0.0 ? medianY : 0.0
        let k = targetGroup.filter { $0.1 > symptomThreshold }.count
        let total = targetGroup.count
        
        let symptomName = symptom.displayName
        
        return "On days when \(conditionPhrase), your \(symptomName) was worse in \(k) out of \(total) logs. Keep tracking to see if this pattern holds up!"
    }
}
