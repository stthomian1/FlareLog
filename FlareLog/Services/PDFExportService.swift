import Foundation
import PDFKit
import UIKit
import FlareLogCore

public final class PDFExportService {
    
    public static func generatePDF(logs: [DailyLog], patterns: [CorrelationResult]) -> Data {
        let pdfMetadata = [
            kCGPDFContextAuthor: "FlareLog App",
            kCGPDFContextSubject: "POTS Wellness Pattern Analysis"
        ] as [CFString: Any]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetadata
        
        // standard US Letter size: 8.5 x 11 inches -> 612 x 792 points
        let pageBounds = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageBounds, format: format)
        
        let data = renderer.pdfData { context in
            // --- PAGE 1 ---
            context.beginPage()
            
            var currentY: CGFloat = 40.0
            let margin: CGFloat = 54.0 // 0.75 in margin
            let contentWidth = pageBounds.width - (margin * 2)
            
            // Header Color Tint Bar
            context.cgContext.setFillColor(UIColor.systemTeal.withAlphaComponent(0.1).cgColor)
            context.cgContext.fill(CGRect(x: margin, y: currentY, width: contentWidth, height: 60))
            
            // Title
            let title = "FlareLog — POTS Journal Report"
            let titleFont = UIFont.boldSystemFont(ofSize: 20)
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.systemTeal
            ]
            title.draw(at: CGPoint(x: margin + 12, y: currentY + 12), withAttributes: titleAttributes)
            
            // Subheader
            let sub = "Generated: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))  |  Analyzed History: \(logs.count) days"
            let subFont = UIFont.systemFont(ofSize: 10)
            let subAttributes: [NSAttributedString.Key: Any] = [
                .font: subFont,
                .foregroundColor: UIColor.secondaryLabel
            ]
            sub.draw(at: CGPoint(x: margin + 12, y: currentY + 36), withAttributes: subAttributes)
            currentY += 80
            
            // Medical Disclaimer Box (Regulatory requirement)
            let disclaimerTitle = "IMPORTANT SAFETY WARNING"
            let disclaimerText = "This report is a personal daily journal to track how you feel. FlareLog is not a doctor, doesn't diagnose illness, recommend treatments, or set limits. Use it to help you talk to your doctor. Always talk to a real physician for medical advice."
            
            let cardRect = CGRect(x: margin, y: currentY, width: contentWidth, height: 75)
            context.cgContext.setFillColor(UIColor.secondarySystemBackground.cgColor)
            context.cgContext.addRect(cardRect)
            context.cgContext.fillPath()
            
            // Left border accent line
            context.cgContext.setStrokeColor(UIColor.systemOrange.cgColor)
            context.cgContext.setLineWidth(3)
            context.cgContext.move(to: CGPoint(x: margin, y: currentY))
            context.cgContext.addLine(to: CGPoint(x: margin, y: currentY + 75))
            context.cgContext.strokePath()
            
            disclaimerTitle.draw(
                in: cardRect.inset(by: UIEdgeInsets(top: 8, left: 12, bottom: 5, right: 12)),
                withAttributes: [
                    .font: UIFont.boldSystemFont(ofSize: 8.5),
                    .foregroundColor: UIColor.systemOrange
                ]
            )
            disclaimerText.draw(
                in: cardRect.inset(by: UIEdgeInsets(top: 22, left: 12, bottom: 5, right: 12)),
                withAttributes: [
                    .font: UIFont.systemFont(ofSize: 8),
                    .foregroundColor: UIColor.label
                ]
            )
            
            currentY += 95
            
            // Observed Patterns
            let sectionTitle = "Surfaced Statistical Patterns"
            sectionTitle.draw(at: CGPoint(x: margin, y: currentY), withAttributes: [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.label
            ])
            currentY += 22
            
            let significantPatterns = patterns.filter { $0.isSignificant }
            if significantPatterns.isEmpty {
                let noPatterns = "No statistically significant patterns were observed in the data yet (requires 14+ logged days and adjusted significance thresholds). Continue logging to analyze your habits."
                let noPatternsAttr: [NSAttributedString.Key: Any] = [
                    .font: UIFont.italicSystemFont(ofSize: 10),
                    .foregroundColor: UIColor.secondaryLabel
                ]
                noPatterns.draw(in: CGRect(x: margin, y: currentY, width: contentWidth, height: 45), withAttributes: noPatternsAttr)
                currentY += 45
            } else {
                for pattern in significantPatterns {
                    let text = "• \(pattern.observationalSentence)"
                    let textFont = UIFont.systemFont(ofSize: 10.5)
                    let textRect = CGRect(x: margin, y: currentY, width: contentWidth, height: 35)
                    
                    // Draw card background for patterns
                    context.cgContext.setFillColor(UIColor.systemGray6.withAlphaComponent(0.5).cgColor)
                    context.cgContext.fill(CGRect(x: margin, y: currentY - 2, width: contentWidth, height: 30))
                    
                    text.draw(in: textRect.insetBy(dx: 6, dy: 4), withAttributes: [
                        .font: textFont,
                        .foregroundColor: UIColor.label
                    ])
                    currentY += 34
                    
                    if currentY > pageBounds.height - 60 {
                        context.beginPage()
                        currentY = 40
                    }
                }
            }
            
            currentY += 15
            
            // Recent Logs Title
            if currentY > pageBounds.height - 120 {
                context.beginPage()
                currentY = 40
            }
            
            let journalTitle = "Recent Tracking Records (Up to 14 days)"
            journalTitle.draw(at: CGPoint(x: margin, y: currentY), withAttributes: [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.label
            ])
            currentY += 20
            
            // Draw Table
            let colWidths: [CGFloat] = [65, 145, 130, 164] // Total: 504
            let headers = ["Date", "Symptom Severities", "Habits / Triggers", "Journal Notes"]
            
            // Header Fill
            context.cgContext.setFillColor(UIColor.systemTeal.withAlphaComponent(0.2).cgColor)
            context.cgContext.fill(CGRect(x: margin, y: currentY, width: contentWidth, height: 20))
            
            var currentX = margin
            for i in 0..<headers.count {
                headers[i].draw(
                    in: CGRect(x: currentX + 6, y: currentY + 4, width: colWidths[i] - 12, height: 14),
                    withAttributes: [
                        .font: UIFont.boldSystemFont(ofSize: 8.5),
                        .foregroundColor: UIColor.label
                    ]
                )
                currentX += colWidths[i]
            }
            currentY += 20
            
            let sortedLogs = logs.sorted { $0.date > $1.date }.prefix(14)
            var index = 0
            
            for log in sortedLogs {
                if currentY > pageBounds.height - 50 {
                    context.beginPage()
                    currentY = 40
                    
                    // Draw header again on new page
                    context.cgContext.setFillColor(UIColor.systemTeal.withAlphaComponent(0.2).cgColor)
                    context.cgContext.fill(CGRect(x: margin, y: currentY, width: contentWidth, height: 20))
                    
                    currentX = margin
                    for i in 0..<headers.count {
                        headers[i].draw(
                            in: CGRect(x: currentX + 6, y: currentY + 4, width: colWidths[i] - 12, height: 14),
                            withAttributes: [.font: UIFont.boldSystemFont(ofSize: 8.5), .foregroundColor: UIColor.label]
                        )
                        currentX += colWidths[i]
                    }
                    currentY += 20
                }
                
                let dateStr = DateFormatter.localizedString(from: log.date, dateStyle: .short, timeStyle: .none)
                
                // Formulate Symptoms Text
                var symptomsList: [String] = []
                if log.symptoms.lightheadedness > 0 { symptomsList.append("Dizzy: \(log.symptoms.lightheadedness)") }
                if log.symptoms.tachycardiaCount > 0 { symptomsList.append("Racing Heart: \(log.symptoms.tachycardiaCount)x (Sev: \(log.symptoms.tachycardiaSeverity))") }
                if log.symptoms.fatigue > 0 { symptomsList.append("Tiredness: \(log.symptoms.fatigue)") }
                if log.symptoms.brainFog > 0 { symptomsList.append("Fog: \(log.symptoms.brainFog)") }
                if log.symptoms.nausea > 0 { symptomsList.append("Nausea: \(log.symptoms.nausea)") }
                if log.symptoms.syncopeExperienced { symptomsList.append("Fainted: \(log.symptoms.syncopeCount)x") }
                let symptomsStr = symptomsList.isEmpty ? "All severity 0" : symptomsList.joined(separator: "\n")
                
                // Formulate Triggers Text
                var triggersList: [String] = []
                if let sleep = log.triggerCandidate.sleepHours { triggersList.append("Sleep: \(sleep)h") }
                if let hyd = log.triggerCandidate.hydrationOunces { triggersList.append("Water: \(Int(hyd)) oz") }
                if let stand = log.triggerCandidate.standingTimeMinutes { triggersList.append("Standing: \(stand)m") }
                if let med = log.triggerCandidate.medicationTakenOnTime { triggersList.append("Med on-time: \(med ? "Yes" : "No")") }
                if let cyc = log.triggerCandidate.menstrualCycleDay { triggersList.append("Cycle day: \(cyc)") }
                if let pressure = log.triggerCandidate.weatherBarometricPressure { triggersList.append("Pressure: \(pressure) hPa") }
                if let act = log.triggerCandidate.activityLevel { triggersList.append("Activity: \(act.rawValue.capitalized)") }
                
                // Add HealthKit if present
                if let hkHr = log.healthKitPull.heartRateAverage { triggersList.append("HK Avg HR: \(Int(hkHr))") }
                if let hkHrv = log.healthKitPull.heartRateVariabilityAverage { triggersList.append("HK HRV: \(Int(hkHrv))ms") }
                if let hkSteps = log.healthKitPull.stepCount { triggersList.append("HK Steps: \(hkSteps)") }
                if let hkSleep = log.healthKitPull.sleepDuration { triggersList.append("HK Sleep: \(String(format: "%.1f", hkSleep))h") }
                
                let triggersStr = triggersList.isEmpty ? "None logged" : triggersList.joined(separator: "\n")
                let notesStr = log.notes ?? ""
                
                let rowData = [dateStr, symptomsStr, triggersStr, notesStr]
                
                // Row height estimation based on text length
                let maxStrLength = max(symptomsStr.count, triggersStr.count, notesStr.count)
                let rowHeight: CGFloat = maxStrLength > 100 ? 55 : (maxStrLength > 40 ? 40 : 26)
                
                // Draw background tint for rows
                if index % 2 == 0 {
                    context.cgContext.setFillColor(UIColor.systemBackground.cgColor)
                } else {
                    context.cgContext.setFillColor(UIColor.secondarySystemBackground.withAlphaComponent(0.4).cgColor)
                }
                context.cgContext.fill(CGRect(x: margin, y: currentY, width: contentWidth, height: rowHeight))
                
                // Draw cell contents
                currentX = margin
                for i in 0..<rowData.count {
                    rowData[i].draw(
                        in: CGRect(x: currentX + 6, y: currentY + 4, width: colWidths[i] - 12, height: rowHeight - 8),
                        withAttributes: [
                            .font: UIFont.systemFont(ofSize: 7.5),
                            .foregroundColor: UIColor.label
                        ]
                    )
                    currentX += colWidths[i]
                }
                
                // Draw separator
                context.cgContext.setStrokeColor(UIColor.separator.cgColor)
                context.cgContext.setLineWidth(0.5)
                context.cgContext.move(to: CGPoint(x: margin, y: currentY + rowHeight))
                context.cgContext.addLine(to: CGPoint(x: pageBounds.width - margin, y: currentY + rowHeight))
                context.cgContext.strokePath()
                
                currentY += rowHeight
                index += 1
            }
        }
        return data
    }
}
