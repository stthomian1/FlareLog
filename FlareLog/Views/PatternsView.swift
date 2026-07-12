import SwiftUI
import SwiftData
import Charts
import FlareLogCore

public struct PatternsView: View {
    @Query(sort: \SDDailyLog.date, order: .reverse) private var logs: [SDDailyLog]
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    @State private var selectedPattern: CorrelationResult? = nil
    @State private var showPaywall: Bool = false
    
    // PDF Export states
    @State private var pdfURL: URL? = nil
    @State private var showShareSheet: Bool = false
    @State private var isGeneratingPDF: Bool = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.09, blue: 0.16)
                .ignoresSafeArea()
            
            if logs.count < 14 {
                // 14-Day threshold state
                ThresholdIndicatorView(count: logs.count)
            } else if !subscriptionManager.isPremium {
                // Paywall gate state
                PatternsPaywallUpsellView(showPaywall: $showPaywall)
            } else {
                // Premium analysis state
                let domainLogs = logs.map { $0.toDomain() }
                let patterns = CorrelationEngine.analyze(logs: domainLogs)
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Header and PDF Button
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("STATISTICAL ANALYSIS")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(.teal)
                                Text("Symptom Patterns")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            
                            // PDF Export Button
                            Button(action: {
                                exportPDFReport(domainLogs: domainLogs, patterns: patterns)
                            }) {
                                HStack(spacing: 6) {
                                    if isGeneratingPDF {
                                        ProgressView()
                                            .tint(.teal)
                                    } else {
                                        Image(systemName: "doc.arrow.up.fill")
                                            .font(.system(size: 14))
                                    }
                                    Text("Export PDF")
                                        .font(.system(size: 13, weight: .bold))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.teal.opacity(0.15))
                                .foregroundColor(.teal)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.teal.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .disabled(isGeneratingPDF)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Main Patterns List
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Observed Correlations")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                            
                            let significant = patterns.filter { $0.isSignificant }
                            
                            if significant.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "chart.bar.doc.horizontal")
                                        .font(.system(size: 44))
                                        .foregroundColor(.white.opacity(0.2))
                                    Text("No patterns found yet!")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text("We haven't found any clear patterns in your logs yet. Keep logging every day so we can spot connections!")
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.4))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 30)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(Color(red: 0.12, green: 0.17, blue: 0.28).opacity(0.4))
                                .cornerRadius(16)
                                .padding(.horizontal, 16)
                            } else {
                                ForEach(significant) { pattern in
                                    PatternCard(pattern: pattern, isSelected: selectedPattern?.id == pattern.id) {
                                        withAnimation {
                                            if selectedPattern?.id == pattern.id {
                                                selectedPattern = nil
                                            } else {
                                                selectedPattern = pattern
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("💡 Reading your patterns:")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white.opacity(0.85))
                                    Text("• Strength shows how closely a habit and symptom follow each other.")
                                        .font(.system(size: 11))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text("• Confidence is how sure we are that the pattern is a real connection and not just a random coincidence.")
                                        .font(.system(size: 11))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.04))
                                .cornerRadius(10)
                                .padding(.horizontal, 16)
                            }
                            }
                        }
                        
                        // Detail Chart Card for Selected Correlation
                        if let pattern = selectedPattern {
                            let pairedData = getPairedDataPoints(for: pattern, domainLogs: domainLogs)
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Visualizing: \(pattern.trigger.displayName) vs \(pattern.symptom.displayName)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Chart {
                                    ForEach(pairedData, id: \.id) { point in
                                        PointMark(
                                            x: .value(pattern.trigger.displayName, point.x),
                                            y: .value(pattern.symptom.displayName, point.y)
                                        )
                                        .foregroundStyle(Color.teal)
                                        .symbolSize(80)
                                    }
                                }
                                .frame(height: 180)
                                .chartXAxis {
                                    AxisMarks(position: .bottom) {
                                        AxisValueLabel()
                                            .foregroundStyle(Color.white.opacity(0.5))
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(position: .leading) {
                                        AxisValueLabel()
                                            .foregroundStyle(Color.white.opacity(0.5))
                                    }
                                }
                                
                                Text("Each dot is one log entry. This chart shows how your habits and symptoms relate.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding(.all, 16)
                            .background(Color(red: 0.12, green: 0.17, blue: 0.28).opacity(0.6))
                            .cornerRadius(16)
                            .padding(.horizontal, 16)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showPaywall) {
            PaywallView(isPresented: $showPaywall)
        }
        .sheet(isPresented: $showShareSheet, onDismiss: { pdfURL = nil }) {
            if let url = pdfURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    // Core data mapping for chart points
    private struct PairedPoint: Identifiable {
        let id = UUID()
        let x: Double
        let y: Double
    }
    
    private func getPairedDataPoints(for pattern: CorrelationResult, domainLogs: [DailyLog]) -> [PairedPoint] {
        return domainLogs.compactMap { log in
            guard let x = pattern.trigger.extractor(log),
                  let y = pattern.symptom.extractor(log) else {
                return nil
            }
            return PairedPoint(x: x, y: y)
        }
    }
    
    private func exportPDFReport(domainLogs: [DailyLog], patterns: [CorrelationResult]) {
        isGeneratingPDF = true
        
        // Run off main thread
        DispatchQueue.global(qos: .userInitiated).async {
            let pdfData = PDFExportService.generatePDF(logs: domainLogs, patterns: patterns)
            
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent("FlareLog_Report.pdf")
            
            do {
                try pdfData.write(to: fileURL)
                DispatchQueue.main.async {
                    self.pdfURL = fileURL
                    self.isGeneratingPDF = false
                    self.showShareSheet = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.isGeneratingPDF = false
                }
            }
        }
    }
}

// 14-Day Progress Circle view
struct ThresholdIndicatorView: View {
    let count: Int
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Collecting Logs")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.05), lineWidth: 12)
                    .frame(width: 140, height: 140)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(count) / 14.0)
                    .stroke(
                        LinearGradient(colors: [.teal, .cyan], startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.easeInOut, value: count)
                
                VStack(spacing: 2) {
                    Text("\(count)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("of 14 days")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(.vertical, 10)
            
            Text("We can find patterns after you track for 14 days.")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Text("We use safe statistical math to check if patterns are real. This stops us from showing false patterns before we have enough data.")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
        }
        .padding(.all, 20)
    }
}

// Patterns Screen Paywall View Blur
struct PatternsPaywallUpsellView: View {
    @Binding var showPaywall: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 64))
                .foregroundColor(.teal)
                .padding(.bottom, 10)
            
            Text("Unlock Pattern Analysis")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Find connections between your sleep, water intake, activity, and symptoms using our smart pattern finder.")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            VStack(alignment: .leading, spacing: 12) {
                Label("Spot patterns between habits and symptoms", systemImage: "checkmark.circle.fill")
                Label("Make sure patterns are real using smart math", systemImage: "checkmark.circle.fill")
                Label("Save and share PDF reports", systemImage: "checkmark.circle.fill")
            }
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(.white.opacity(0.9))
            .padding(.vertical, 10)
            
            Button(action: { showPaywall = true }) {
                Text("View Subscription Plans")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 14)
                    .background(Color.teal)
                    .cornerRadius(12)
                    .shadow(color: .teal.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.all, 24)
    }
}

// Card showing single pattern
struct PatternCard: View {
    let pattern: CorrelationResult
    let isSelected: Bool
    let action: () -> Void
    
    private func patternStrengthText(_ r: Double) -> String {
        let absR = abs(r)
        if absR >= 0.6 {
            return "Strong"
        } else if absR >= 0.3 {
            return "Moderate"
        } else {
            return "Weak"
        }
    }
    
    private func patternConfidenceText(_ p: Double) -> String {
        if p <= 0.01 {
            return "High"
        } else if p <= 0.05 {
            return "Medium"
        } else {
            return "Low"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    // Accent indicator color based on direction
                    Circle()
                        .fill(pattern.r > 0 ? Color.orange : Color.teal)
                        .frame(width: 8, height: 8)
                    
                    Text("\(pattern.trigger.displayName.capitalized) vs \(pattern.symptom.displayName.capitalized)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Text(pattern.observationalSentence)
                    .font(.system(size: 12.5))
                    .foregroundColor(.white.opacity(0.85))
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 16) {
                    Text("Strength: \(patternStrengthText(pattern.r))")
                    Text("Confidence: \(patternConfidenceText(pattern.adjustedPValue))")
                    Text("Logged: \(pattern.sampleSize) days")
                }
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.45))
            }
            .padding(.all, 14)
            .background(Color(red: 0.12, green: 0.17, blue: 0.28).opacity(isSelected ? 0.9 : 0.6))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.teal.opacity(0.5) : Color.white.opacity(0.04), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// ShareSheet UIKit Wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    public func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
