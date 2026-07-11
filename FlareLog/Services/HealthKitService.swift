import Foundation
import HealthKit
import FlareLogCore

@MainActor
public final class HealthKitService: ObservableObject {
    @Published public var isAuthorized: Bool = false
    @Published public var isRequesting: Bool = false
    @Published public var errorMessage: String? = nil
    
    private let healthStore = HKHealthStore()
    
    public init() {
        self.checkAuthorizationStatus()
    }
    
    private var typesToRead: Set<HKObjectType> {
        var types = Set<HKObjectType>()
        if let hr = HKQuantityType.quantityType(forIdentifier: .heartRate) { types.insert(hr) }
        if let hrv = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) { types.insert(hrv) }
        if let steps = HKQuantityType.quantityType(forIdentifier: .stepCount) { types.insert(steps) }
        if let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) { types.insert(sleep) }
        return types
    }
    
    public func checkAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else {
            self.isAuthorized = false
            return
        }
        
        // Note: For privacy reasons, iOS does not expose the actual authorization status for read types.
        // But we can check whether requestAuthorization has been triggered.
        // We will assume authorized if we completed request.
        self.isAuthorized = UserDefaults.standard.bool(forKey: "hasRequestedHealthKit")
    }
    
    public func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            self.errorMessage = "HealthKit is not available on this device."
            return
        }
        
        self.isRequesting = true
        self.errorMessage = nil
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            UserDefaults.standard.set(true, forKey: "hasRequestedHealthKit")
            self.isAuthorized = true
        } catch {
            self.errorMessage = "Failed to authorize HealthKit: \(error.localizedDescription)"
            self.isAuthorized = false
        }
        
        self.isRequesting = false
    }
    
    public func fetchDailyData(for date: Date) async -> HealthKitPull {
        guard HKHealthStore.isHealthDataAvailable() && isAuthorized else {
            return HealthKitPull()
        }
        
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        // Fetch steps
        let steps = await fetchStepCount(predicate: predicate)
        
        // Fetch heart rates
        let (avgHR, minHR, maxHR) = await fetchHeartRateMetrics(predicate: predicate)
        
        // Fetch HRV
        let hrv = await fetchHRVMetrics(predicate: predicate)
        
        // Fetch sleep
        let sleep = await fetchSleepDuration(predicate: predicate)
        
        return HealthKitPull(
            heartRateAverage: avgHR,
            heartRateMin: minHR,
            heartRateMax: maxHR,
            heartRateVariabilityAverage: hrv,
            sleepDuration: sleep,
            stepCount: steps
        )
    }
    
    private func fetchStepCount(predicate: NSPredicate) async -> Int? {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return nil }
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, _ in
                guard let sum = result?.sumQuantity() else {
                    continuation.resume(returning: nil)
                    return
                }
                let steps = Int(sum.doubleValue(for: HKUnit.count()))
                continuation.resume(returning: steps)
            }
            healthStore.execute(query)
        }
    }
    
    private func fetchHeartRateMetrics(predicate: NSPredicate) async -> (avg: Double?, min: Double?, max: Double?) {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return (nil, nil, nil) }
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: hrType,
                quantitySamplePredicate: predicate,
                options: [.discreteAverage, .discreteMin, .discreteMax]
            ) { _, result, _ in
                guard let stats = result else {
                    continuation.resume(returning: (nil, nil, nil))
                    return
                }
                let avg = stats.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                let minVal = stats.minimumQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                let maxVal = stats.maximumQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                
                continuation.resume(returning: (avg, minVal, maxVal))
            }
            healthStore.execute(query)
        }
    }
    
    private func fetchHRVMetrics(predicate: NSPredicate) async -> Double? {
        guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else { return nil }
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: hrvType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, _ in
                guard let stats = result, let avg = stats.averageQuantity() else {
                    continuation.resume(returning: nil)
                    return
                }
                let hrv = avg.doubleValue(for: HKUnit.secondUnit(with: .milli))
                continuation.resume(returning: hrv)
            }
            healthStore.execute(query)
        }
    }
    
    private func fetchSleepDuration(predicate: NSPredicate) async -> Double? {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return nil }
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, _ in
                guard let sleepSamples = samples as? [HKCategorySample], !sleepSamples.isEmpty else {
                    continuation.resume(returning: nil)
                    return
                }
                
                // Sum durations of asleep states
                var totalSeconds: TimeInterval = 0.0
                for sample in sleepSamples {
                    // HKCategoryValueSleepAnalysis.asleep is the value for being asleep.
                    // Note: HealthKit sleep analysis has multiple values (.asleep, .asleepCore, .asleepDeep, .asleepREM, etc.)
                    // In iOS 16, asleep matches the integer values corresponding to sleep.
                    // We sum all values that indicate being asleep (non-awake)
                    #if swift(>=5.7)
                    if sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue ||
                       sample.value == 2 || // asleepCore / asleepDeep
                       sample.value == 3 || // REM
                       sample.value == 4 || // unspec asleep
                       sample.value == 5 {  // asleepDeep
                        totalSeconds += sample.endDate.timeIntervalSince(sample.startDate)
                    }
                    #else
                    if sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                        totalSeconds += sample.endDate.timeIntervalSince(sample.startDate)
                    }
                    #endif
                }
                
                let hours = totalSeconds / 3600.0
                continuation.resume(returning: hours > 0 ? hours : nil)
            }
            healthStore.execute(query)
        }
    }
}
