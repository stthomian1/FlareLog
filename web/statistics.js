/**
 * FlareLog — Statistical Correlation Engine (JavaScript Port)
 */

const ALPHA = 0.05;
const MINIMUM_DAYS_THRESHOLD = 14;

// Helper variables definitions
const TRIGGERS = [
    {
        id: "sleepHours",
        displayName: "sleep time",
        unit: "hours",
        extractor: log => log.triggerCandidate?.sleepHours,
        lowString: "you slept under",
        highString: "you slept over"
    },
    {
        id: "hydration",
        displayName: "water intake",
        unit: "oz",
        extractor: log => log.triggerCandidate?.hydrationOunces,
        lowString: "you drank under",
        highString: "you drank over"
    },
    {
        id: "standingTime",
        displayName: "standing time",
        unit: "minutes",
        extractor: log => log.triggerCandidate?.standingTimeMinutes,
        lowString: "you stood for under",
        highString: "you stood for over"
    },
    {
        id: "medication",
        displayName: "taking meds on time",
        unit: "",
        extractor: log => log.triggerCandidate?.medicationTakenOnTime ? 1.0 : 0.0,
        lowString: "you missed your meds",
        highString: "you took your meds on time"
    },
    {
        id: "menstrualCycleDay",
        displayName: "period cycle day",
        unit: "day",
        extractor: log => log.triggerCandidate?.menstrualCycleDay,
        lowString: "your period cycle day was under",
        highString: "your period cycle day was over"
    },
    {
        id: "barometricPressure",
        displayName: "air pressure (barometer)",
        unit: "hPa",
        extractor: log => log.triggerCandidate?.weatherBarometricPressure,
        lowString: "air pressure was under",
        highString: "air pressure was over"
    },
    {
        id: "activityLevel",
        displayName: "activity level",
        unit: "",
        extractor: log => {
            const val = log.triggerCandidate?.activityLevel;
            if (val === "rest") return 0.0;
            if (val === "light") return 1.0;
            if (val === "moderate") return 2.0;
            if (val === "vigorous") return 3.0;
            return null;
        },
        lowString: "you were mostly resting",
        highString: "you were super active"
    },
    // HealthKit Mock data
    {
        id: "hkSleep",
        displayName: "HealthKit sleep time",
        unit: "hours",
        extractor: log => log.healthKitPull?.sleepDuration,
        lowString: "Apple Health said you slept under",
        highString: "Apple Health said you slept over"
    },
    {
        id: "hkSteps",
        displayName: "HealthKit steps",
        unit: "steps",
        extractor: log => log.healthKitPull?.stepCount,
        lowString: "Apple Health steps were under",
        highString: "Apple Health steps were over"
    },
    {
        id: "hkHR",
        displayName: "avg heart rate",
        unit: "bpm",
        extractor: log => log.healthKitPull?.heartRateAverage,
        lowString: "your average heart rate was under",
        highString: "your average heart rate was over"
    },
    {
        id: "hkHRV",
        displayName: "avg heart rate variability (HRV)",
        unit: "ms",
        extractor: log => log.healthKitPull?.heartRateVariabilityAverage,
        lowString: "your HRV was under",
        highString: "your HRV was over"
    }
];

const SYMPTOMS = [
    {
        id: "lightheadedness",
        displayName: "dizziness",
        unit: "/10",
        extractor: log => log.symptoms?.lightheadedness
    },
    {
        id: "tachycardiaSeverity",
        displayName: "racing heart severity",
        unit: "/10",
        extractor: log => log.symptoms?.tachycardiaSeverity
    },
    {
        id: "tachycardiaCount",
        displayName: "racing heart episodes",
        unit: "episodes",
        extractor: log => log.symptoms?.tachycardiaCount
    },
    {
        id: "fatigue",
        displayName: "tiredness",
        unit: "/10",
        extractor: log => log.symptoms?.fatigue
    },
    {
        id: "brainFog",
        displayName: "brain fog",
        unit: "/10",
        extractor: log => log.symptoms?.brainFog
    },
    {
        id: "nausea",
        displayName: "nausea",
        unit: "/10",
        extractor: log => log.symptoms?.nausea
    },
    {
        id: "syncopeCount",
        displayName: "fainting episodes",
        unit: "episodes",
        extractor: log => log.symptoms?.syncopeCount
    }
];

/**
 * Standard numerical approximation for error function (erf)
 * Abramowitz and Stegun formula 7.1.26
 */
function errorFunction(x) {
    const p = 0.3275911;
    const a1 = 0.254829592;
    const a2 = -0.284496736;
    const a3 = 1.421413741;
    const a4 = -1.453152027;
    const a5 = 1.061405429;
    
    const absX = Math.abs(x);
    const t = 1.0 / (1.0 + p * absX);
    const erfVal = 1.0 - ((((a5 * t + a4) * t + a3) * t + a2) * t + a1) * t * Math.exp(-x * x);
    return x >= 0 ? erfVal : -erfVal;
}

/**
 * Calculate Pearson correlation and raw p-value
 */
function calculatePearsonCorrelation(pairedPoints) {
    const n = pairedPoints.length;
    const sumX = pairedPoints.reduce((sum, p) => sum + p[0], 0);
    const sumY = pairedPoints.reduce((sum, p) => sum + p[1], 0);
    
    const meanX = sumX / n;
    const meanY = sumY / n;
    
    let num = 0.0;
    let denX = 0.0;
    let denY = 0.0;
    
    for (const point of pairedPoints) {
        const diffX = point[0] - meanX;
        const diffY = point[1] - meanY;
        num += diffX * diffY;
        denX += diffX * diffX;
        denY += diffY * diffY;
    }
    
    if (denX === 0.0 || denY === 0.0) {
        return { r: 0.0, pValue: 1.0 };
    }
    
    const r = num / Math.sqrt(denX * denY);
    const clampedR = Math.max(-0.99999, Math.min(0.99999, r));
    
    // Calculate t-statistic
    const df = n - 2;
    const t = Math.abs(clampedR) * Math.sqrt(df / (1.0 - clampedR * clampedR));
    
    // Wallace approximation for Student's t CDF to standard normal Z
    const z = (t * (1.0 - 0.25 / df)) / Math.sqrt(1.0 + (t * t) / (2.0 * df));
    
    // Two-tailed p-value
    const pValue = 1.0 - errorFunction(z / Math.sqrt(2.0));
    
    return { r, pValue };
}

/**
 * Helper to calculate median
 */
function calculateMedian(arr) {
    if (arr.length === 0) return 0;
    const sorted = [...arr].sort((a, b) => a - b);
    const mid = Math.floor(sorted.length / 2);
    return sorted.length % 2 !== 0 ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2;
}

/**
 * Generate Dynamic Observational, non-causal copy
 */
function generateObservationalSentence(trigger, symptom, r, pairedPoints) {
    const xValues = pairedPoints.map(p => p[0]);
    const yValues = pairedPoints.map(p => p[1]);
    
    const medianX = calculateMedian(xValues);
    const medianY = calculateMedian(yValues);
    
    let targetGroup;
    let conditionPhrase;
    
    let formattedMedianX = Number(medianX.toFixed(1));
    if (trigger.id === "activityLevel") {
        if (medianX <= 0.5) formattedMedianX = "rest";
        else if (medianX <= 1.5) formattedMedianX = "light";
        else if (medianX <= 2.5) formattedMedianX = "moderate";
        else formattedMedianX = "vigorous";
    }
    
    if (trigger.id === "medication") {
        if (r > 0) {
            targetGroup = pairedPoints.filter(p => p[0] >= 0.5);
            conditionPhrase = "you took your meds on time";
        } else {
            targetGroup = pairedPoints.filter(p => p[0] < 0.5);
            conditionPhrase = "you missed your meds";
        }
    } else {
        if (r > 0) {
            targetGroup = pairedPoints.filter(p => p[0] > medianX);
            conditionPhrase = `${trigger.highString} ${formattedMedianX}${trigger.unit ? ' ' + trigger.unit : ''}`;
        } else {
            targetGroup = pairedPoints.filter(p => p[0] <= medianX);
            conditionPhrase = `${trigger.lowString} ${formattedMedianX}${trigger.unit ? ' ' + trigger.unit : ''}`;
        }
    }
    
    const symptomThreshold = medianY > 0.0 ? medianY : 0.0;
    const k = targetGroup.filter(p => p[1] > symptomThreshold).length;
    const total = targetGroup.length;
    
    return `On days when ${conditionPhrase}, your ${symptom.displayName} was worse in ${k} out of ${total} logs. Keep tracking to see if this pattern holds up!`;
}

/**
 * Core analysis run
 */
function analyzeCorrelations(logs) {
    const rawResults = [];
    
    for (const trigger of TRIGGERS) {
        for (const symptom of SYMPTOMS) {
            const pairedPoints = [];
            
            for (const log of logs) {
                const x = trigger.extractor(log);
                const y = symptom.extractor(log);
                
                if (x !== undefined && x !== null && y !== undefined && y !== null) {
                    pairedPoints.push([Number(x), Number(y)]);
                }
            }
            
            // Only perform if enough paired samples are present
            if (pairedPoints.length < MINIMUM_DAYS_THRESHOLD) {
                continue;
            }
            
            const { r, pValue } = calculatePearsonCorrelation(pairedPoints);
            const sentence = generateObservationalSentence(trigger, symptom, r, pairedPoints);
            
            rawResults.push({
                id: `${trigger.id}-${symptom.id}`,
                trigger,
                symptom,
                r,
                pValue,
                adjustedPValue: 1.0,
                isSignificant: false,
                observationalSentence: sentence,
                sampleSize: pairedPoints.length
            });
        }
    }
    
    if (rawResults.length === 0) return [];
    
    // Sort results by raw p-value ascending
    const M = rawResults.length;
    const sortedIndices = Array.from({ length: M }, (_, i) => i)
        .sort((a, b) => rawResults[a].pValue - rawResults[b].pValue);
        
    let minFutureVal = Infinity;
    const adjustedPValues = Array(M).fill(1.0);
    
    for (let idxInSorted = M - 1; idxInSorted >= 0; idxInSorted--) {
        const originalIndex = sortedIndices[idxInSorted];
        const pValue = rawResults[originalIndex].pValue;
        const rank = idxInSorted + 1;
        const rawAdjusted = pValue * M / rank;
        minFutureVal = Math.min(minFutureVal, rawAdjusted);
        adjustedPValues[idxInSorted] = Math.min(1.0, Math.max(0.0, minFutureVal));
    }
    
    // Write back and evaluate significance
    for (let rankIndex = 0; rankIndex < M; rankIndex++) {
        const originalIndex = sortedIndices[rankIndex];
        const adjustedP = adjustedPValues[rankIndex];
        rawResults[originalIndex].adjustedPValue = adjustedP;
        rawResults[originalIndex].isSignificant = adjustedP <= ALPHA;
    }
    
    return rawResults;
}

// Attach to window for modular usage
window.CorrelationEngine = {
    TRIGGERS,
    SYMPTOMS,
    analyze: analyzeCorrelations
};
