import XCTest
@testable import FlareLogCore

final class CorrelationEngineTests: XCTestCase {
    
    // Helper to generate a date offset by days
    private func dateOffsetBy(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: Date())!
    }
    
    func testMinimumFourteenDaysThreshold() {
        // Test case A: Total 10 days logged
        var tenDaysLogs: [DailyLog] = []
        for i in 0..<10 {
            let log = DailyLog(
                date: dateOffsetBy(days: -i),
                symptoms: SymptomEntry(lightheadedness: 5),
                triggerCandidate: TriggerCandidate(sleepHours: 8.0)
            )
            tenDaysLogs.append(log)
        }
        
        let resultsShort = CorrelationEngine.analyze(logs: tenDaysLogs)
        XCTAssertTrue(resultsShort.isEmpty, "Should return no correlations if less than 14 days are logged")
        
        // Test case B: 15 days total, but only 10 days have sleepHours logged
        var partialLogs: [DailyLog] = []
        for i in 0..<15 {
            let hasSleep = i < 10
            let log = DailyLog(
                date: dateOffsetBy(days: -i),
                symptoms: SymptomEntry(lightheadedness: 5),
                triggerCandidate: TriggerCandidate(sleepHours: hasSleep ? 8.0 : nil)
            )
            partialLogs.append(log)
        }
        
        let resultsPartial = CorrelationEngine.analyze(logs: partialLogs)
        XCTAssertTrue(resultsPartial.isEmpty, "Should return no correlations for sleepHours since its valid sample size is 10 (< 14)")
    }
    
    func testPlantedCorrelationSurfaces() {
        // Generate 20 days with a clear negative correlation between sleepHours and lightheadedness
        // More sleep -> lower lightheadedness; Less sleep -> higher lightheadedness
        var logs: [DailyLog] = []
        
        for i in 0..<20 {
            // Sleep ranges from 4.0 to 9.0 hours
            let sleep = 4.0 + Double(i % 6) // 4, 5, 6, 7, 8, 9
            
            // Symptom severity has a strong inverse relation with sleep
            // E.g., sleep 4 -> lightheadedness 9, sleep 9 -> lightheadedness 1
            let baseLightheadedness = Int(13.0 - sleep) // 9, 8, 7, 6, 5, 4
            let noise = (i % 2 == 0) ? -1 : 1
            let lightheadedness = max(0, min(10, baseLightheadedness + noise))
            
            let log = DailyLog(
                date: dateOffsetBy(days: -i),
                symptoms: SymptomEntry(lightheadedness: lightheadedness),
                triggerCandidate: TriggerCandidate(
                    sleepHours: sleep,
                    hydrationLiters: 2.0 // constant, no correlation
                )
            )
            logs.append(log)
        }
        
        let results = CorrelationEngine.analyze(logs: logs)
        
        // Find sleepHours vs lightheadedness
        let sleepVsLightheaded = results.first { $0.trigger.id == "sleepHours" && $0.symptom.id == "lightheadedness" }
        
        XCTAssertNotNil(sleepVsLightheaded, "Should analyze sleepHours vs lightheadedness")
        
        guard let correlation = sleepVsLightheaded else { return }
        
        // Pearson correlation should be strong negative
        XCTAssertTrue(correlation.r < -0.6, "Expected a strong negative correlation coefficient, got r = \(correlation.r)")
        
        // P-value should be very small
        XCTAssertTrue(correlation.pValue < 0.05, "Raw p-value should be small, got p = \(correlation.pValue)")
        
        // BH correction should preserve significance
        XCTAssertTrue(correlation.isSignificant, "Should be flagged as significant after BH adjustment")
        XCTAssertTrue(correlation.adjustedPValue <= 0.05, "Adjusted p-value should be <= 0.05")
        
        // Check sentence format and content
        let sentence = correlation.observationalSentence
        XCTAssertTrue(sentence.contains("On days you logged under"), "Copy should use observational 'logged under'")
        XCTAssertTrue(sentence.contains("sleep duration"), "Copy should mention 'sleep duration'")
        XCTAssertTrue(sentence.contains("lightheadedness severity was higher"), "Copy should mention 'lightheadedness severity was higher'")
        XCTAssertTrue(sentence.contains("Log more days to confirm this pattern."), "Copy must contain the non-causal disclaimer")
        
        // Check that non-correlated hydration variable did not trigger a pattern
        let hydrationVsLightheaded = results.first { $0.trigger.id == "hydration" && $0.symptom.id == "lightheadedness" }
        if let hydCorr = hydrationVsLightheaded {
            XCTAssertFalse(hydCorr.isSignificant, "Constant hydration should not surface as a significant pattern")
        }
    }
    
    func testRandomNoiseNoFalsePositives() {
        // Generate 30 days of purely random variables
        // This ensures the BH adjustment prevents spurious correlations from being reported as patterns
        var logs: [DailyLog] = []
        
        // Use a fixed seed-like progression for reproducibility in test
        for i in 0..<30 {
            let sleep = 4.0 + Double((i * 7 + 3) % 7) // pseudo-random between 4 and 10
            let hydration = 1.0 + Double((i * 13 + 5) % 3) // pseudo-random between 1 and 3
            let standing = 10 + ((i * 17 + 2) % 100) // pseudo-random minutes
            
            let lightheadedness = (i * 3 + 1) % 11 // 0-10
            let fatigue = (i * 5 + 4) % 11 // 0-10
            let brainFog = (i * 11 + 7) % 11 // 0-10
            
            let log = DailyLog(
                date: dateOffsetBy(days: -i),
                symptoms: SymptomEntry(
                    lightheadedness: lightheadedness,
                    fatigue: fatigue,
                    brainFog: brainFog
                ),
                triggerCandidate: TriggerCandidate(
                    sleepHours: sleep,
                    hydrationLiters: hydration,
                    standingTimeMinutes: standing
                )
            )
            logs.append(log)
        }
        
        let results = CorrelationEngine.analyze(logs: logs)
        
        // Filter for significant correlations
        let significantResults = results.filter { $0.isSignificant }
        
        // With purely random data, the Benjamini-Hochberg correction should reject all or nearly all comparisons,
        // preventing them from being flagged as patterns.
        XCTAssertTrue(significantResults.isEmpty, "No patterns should be surfaced for purely random noise under BH correction. Found: \(significantResults.map { "\($0.trigger.id) vs \($0.symptom.id) (r=\($0.r), adjP=\($0.adjustedPValue))" })")
    }
}
