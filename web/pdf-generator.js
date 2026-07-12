/**
 * FlareLog — Client-Side PDF Report Generator
 */

(function() {
    
    function downloadPDF(logs, patterns) {
        // Instantiate jsPDF from window global
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF({
            orientation: "portrait",
            unit: "pt",
            format: "letter" // 612 pt x 792 pt
        });
        
        let currentY = 40;
        const margin = 54; // 0.75 in
        const contentWidth = 504;
        
        // --- PAGE 1: HEADER & STATS ---
        // Header Blue/Teal bar
        doc.setFillColor(224, 242, 254); // Light teal tint
        doc.rect(margin, currentY, contentWidth, 60, "F");
        
        // Title
        doc.setFont("helvetica", "bold");
        doc.setFontSize(18);
        doc.setTextColor(14, 165, 233);
        doc.text("FlareLog — POTS Journal Report", margin + 12, currentY + 24);
        
        // Subtitle
        const dateStr = new Date().toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' });
        doc.setFont("helvetica", "normal");
        doc.setFontSize(9.5);
        doc.setTextColor(100, 116, 139);
        doc.text(`Generated: ${dateStr}  |  Analyzed History: ${logs.length} days`, margin + 12, currentY + 44);
        
        currentY += 80;
        
        // Medical Disclaimer Card (Regulatory requirement)
        doc.setFillColor(245, 245, 245);
        doc.rect(margin, currentY, contentWidth, 75, "F");
        
        // Left border orange accent line
        doc.setFillColor(249, 115, 22); // Orange
        doc.rect(margin, currentY, 3, 75, "F");
        
        doc.setFont("helvetica", "bold");
        doc.setFontSize(8.5);
        doc.setTextColor(249, 115, 22); // Orange text
        doc.text("IMPORTANT SAFETY WARNING", margin + 12, currentY + 16);
        
        const disclaimerText = "This report is a personal daily journal to track how you feel. FlareLog is not a doctor, doesn't diagnose illness, recommend treatments, or set limits. Use it to help you talk to your doctor. Always talk to a real physician for medical advice.";
        const disclaimerLines = doc.splitTextToSize(disclaimerText, contentWidth - 24);
        
        doc.setFont("helvetica", "normal");
        doc.setFontSize(8);
        doc.setTextColor(0, 0, 0);
        doc.text(disclaimerLines, margin + 12, currentY + 28);
        
        currentY += 95;
        
        // Surfaced Patterns Section
        doc.setFont("helvetica", "bold");
        doc.setFontSize(13);
        doc.setTextColor(0, 0, 0);
        doc.text("Surfaced Statistical Patterns", margin, currentY);
        
        currentY += 22;
        
        const significant = patterns.filter(p => p.isSignificant);
        if (significant.length === 0) {
            doc.setFont("helvetica", "italic");
            doc.setFontSize(10);
            doc.setTextColor(100, 116, 139);
            doc.text("No statistically significant patterns were observed in the data yet (requires 14+ logged days and adjusted significance thresholds). Continue logging to analyze your habits.", margin, currentY);
            currentY += 40;
        } else {
            for (const pattern of significant) {
                const sentenceText = `• ${pattern.observationalSentence}`;
                const sentenceLines = doc.splitTextToSize(sentenceText, contentWidth - 24);
                
                // Calculate dynamic heights based on text wrapping
                const lineHeight = 12;
                const sentenceHeight = sentenceLines.length * lineHeight;
                const statLineOffset = sentenceHeight + 10;
                const cardHeight = statLineOffset + 14;
                
                // Pagination check before drawing the card
                if (currentY + cardHeight > 740) {
                    doc.addPage();
                    currentY = 40;
                }
                
                // Background card for patterns
                doc.setFillColor(248, 250, 252);
                doc.rect(margin, currentY - 2, contentWidth, cardHeight, "F");
                
                // Draw observational sentence
                doc.setFont("helvetica", "normal");
                doc.setFontSize(9.5);
                doc.setTextColor(0, 0, 0);
                doc.text(sentenceLines, margin + 8, currentY + 10);
                
                // Add tiny stat line
                doc.setFont("courier", "normal");
                doc.setFontSize(7.5);
                doc.setTextColor(100, 116, 139);
                
                const absR = Math.abs(pattern.r);
                const strength = absR >= 0.6 ? "Strong" : (absR >= 0.3 ? "Moderate" : "Weak");
                const confidence = pattern.adjustedPValue <= 0.01 ? "High" : (pattern.adjustedPValue <= 0.05 ? "Medium" : "Low");
                
                doc.text(`Strength: ${strength}  Confidence: ${confidence}  Sample: ${pattern.sampleSize} days`, margin + 14, currentY + statLineOffset);
                
                currentY += cardHeight + 8; // Leave a space of 8pt between cards
            }
        }
        
        currentY += 15;
        
        // Recent Logs Section
        if (currentY > 680) {
            doc.addPage();
            currentY = 40;
        }
        
        doc.setFont("helvetica", "bold");
        doc.setFontSize(13);
        doc.setTextColor(0, 0, 0);
        doc.text("Recent Tracking Records (Up to 14 days)", margin, currentY);
        currentY += 20;
        
        // Draw Table Header
        const colWidths = [65, 145, 130, 164]; // Total: 504 pt
        const headers = ["Date", "Symptom Severities", "Habits / Triggers", "Journal Notes"];
        
        // Header Fill
        doc.setFillColor(224, 242, 254);
        doc.rect(margin, currentY, contentWidth, 20, "F");
        
        doc.setFont("helvetica", "bold");
        doc.setFontSize(8.5);
        doc.setTextColor(0, 0, 0);
        
        let currentX = margin;
        for (let i = 0; i < headers.count || i < headers.length; i++) {
            doc.text(headers[i], currentX + 6, currentY + 13);
            currentX += colWidths[i];
        }
        
        currentY += 20;
        
        // Sort logs newest first, take top 14
        const sortedLogs = [...logs].sort((a, b) => b.date - a.date).slice(0, 14);
        
        sortedLogs.forEach((log, index) => {
            // Height estimation based on notes size
            const notesText = log.notes || "";
            const notesLines = doc.splitTextToSize(notesText, colWidths[3] - 12);
            
            // Build symptoms details string
            const symptomsList = [];
            const s = log.symptoms;
            if (s.lightheadedness > 0) symptomsList.push(`Dizzy: ${s.lightheadedness}`);
            if (s.tachycardiaCount > 0) symptomsList.push(`Racing Heart: ${s.tachycardiaCount}x (Sev: ${s.tachycardiaSeverity})`);
            if (s.fatigue > 0) symptomsList.push(`Tiredness: ${s.fatigue}`);
            if (s.brainFog > 0) symptomsList.push(`Fog: ${s.brainFog}`);
            if (s.nausea > 0) symptomsList.push(`Nausea: ${s.nausea}`);
            if (s.syncopeExperienced) symptomsList.push(`Fainted: ${s.syncopeCount}x`);
            const symptomsStr = symptomsList.length === 0 ? "All severity 0" : symptomsList.join("\n");
            
            // Build habits details string
            const triggersList = [];
            const t = log.triggerCandidate;
            if (t.sleepHours !== undefined) triggersList.push(`Sleep: ${t.sleepHours}h`);
            if (t.hydrationOunces !== undefined) triggersList.push(`Water: ${t.hydrationOunces} oz`);
            if (t.standingTimeMinutes !== undefined) triggersList.push(`Standing: ${t.standingTimeMinutes}m`);
            if (t.medicationTakenOnTime !== undefined) triggersList.push(`Med on-time: ${t.medicationTakenOnTime ? "Yes" : "No"}`);
            if (t.menstrualCycleDay !== undefined && t.menstrualCycleDay !== null) triggersList.push(`Cycle day: ${t.menstrualCycleDay}`);
            if (t.weatherBarometricPressure !== undefined && t.weatherBarometricPressure !== null) triggersList.push(`Pressure: ${t.weatherBarometricPressure}hPa`);
            if (t.activityLevel !== undefined) triggersList.push(`Activity: ${capitalize(t.activityLevel)}`);
            
            // Add HealthKit passive pull data if present
            const hk = log.healthKitPull;
            if (hk && hk.heartRateAverage !== undefined) triggersList.push(`HK Avg HR: ${hk.heartRateAverage}`);
            if (hk && hk.heartRateVariabilityAverage !== undefined) triggersList.push(`HK HRV: ${hk.heartRateVariabilityAverage}ms`);
            if (hk && hk.stepCount !== undefined) triggersList.push(`HK Steps: ${hk.stepCount}`);
            if (hk && hk.sleepDuration !== undefined) triggersList.push(`HK Sleep: ${hk.sleepDuration}h`);
            
            const triggersStr = triggersList.length === 0 ? "None logged" : triggersList.join("\n");
            
            // Render row text cells lines
            const sympLines = doc.splitTextToSize(symptomsStr, colWidths[1] - 12);
            const trigLines = doc.splitTextToSize(triggersStr, colWidths[2] - 12);
            
            const maxLines = Math.max(sympLines.length, trigLines.length, notesLines.length, 1);
            const rowHeight = Math.max(26, maxLines * 10 + 10);
            
            // Pagination check
            if (currentY + rowHeight > 740) {
                doc.addPage();
                currentY = 40;
                
                // Draw headers again
                doc.setFillColor(224, 242, 254);
                doc.rect(margin, currentY, contentWidth, 20, "F");
                
                doc.setFont("helvetica", "bold");
                doc.setFontSize(8.5);
                doc.setTextColor(0, 0, 0);
                
                currentX = margin;
                for (let i = 0; i < headers.length; i++) {
                    doc.text(headers[i], currentX + 6, currentY + 13);
                    currentX += colWidths[i];
                }
                
                currentY += 20;
            }
            
            // Alternating fill
            if (index % 2 === 0) {
                doc.setFillColor(255, 255, 255);
            } else {
                doc.setFillColor(248, 250, 252);
            }
            doc.rect(margin, currentY, contentWidth, rowHeight, "F");
            
            doc.setFont("helvetica", "normal");
            doc.setFontSize(7.5);
            doc.setTextColor(0, 0, 0);
            
            // Cell 1: Date
            const formattedDate = new Date(log.date).toLocaleDateString(undefined, { month: 'numeric', day: 'numeric', year: '2-digit' });
            doc.text(formattedDate, margin + 6, currentY + 12);
            
            // Cell 2: Symptoms
            doc.text(sympLines, margin + colWidths[0] + 6, currentY + 12);
            
            // Cell 3: Habits / Triggers
            doc.text(trigLines, margin + colWidths[0] + colWidths[1] + 6, currentY + 12);
            
            // Cell 4: Notes
            doc.text(notesLines, margin + colWidths[0] + colWidths[1] + colWidths[2] + 6, currentY + 12);
            
            // Separator border
            doc.setDrawColor(226, 232, 240);
            doc.setLineWidth(0.5);
            doc.line(margin, currentY + rowHeight, margin + contentWidth, currentY + rowHeight);
            
            currentY += rowHeight;
        });
        
        // Save
        doc.save("FlareLog_Report.pdf");
    }
    
    function capitalize(str) {
        if (!str) return "";
        return str.charAt(0).toUpperCase() + str.slice(1);
    }
    
    // Bind to window global namespaces
    window.PDFGenerator = {
        downloadPDF: downloadPDF
    };
    
})();
