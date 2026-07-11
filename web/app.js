/**
 * FlareLog — Main Application & DOM Controller
 */

document.addEventListener("DOMContentLoaded", () => {
    // --- APP STATE ---
    let logs = JSON.parse(localStorage.getItem("flarelog_logs") || "[]");
    let isPremium = localStorage.getItem("flarelog_premium") === "true";
    let isDisclaimerAccepted = localStorage.getItem("flarelog_disclaimer_accepted") === "true";
    let isHKConnected = localStorage.getItem("flarelog_hk_connected") === "true";
    
    let currentEditingId = null;
    let chartInstance = null;
    let selectedPatternId = null;
    let currentFormHKData = null; // Temp storage for HealthKit sync in current log form

    // --- DOM CACHE ---
    const disclaimerModal = document.getElementById("disclaimer-modal");
    const btnAcceptDisclaimer = document.getElementById("btn-accept-disclaimer");
    const paywallModal = document.getElementById("paywall-modal");
    const btnClosePaywall = document.getElementById("btn-close-paywall");
    const btnSubscribe = document.getElementById("btn-subscribe");
    const btnRestore = document.getElementById("btn-restore");
    const premiumBadge = document.getElementById("premium-badge");

    // Navigation
    const navTabs = document.querySelectorAll(".nav-tab");
    const appViews = document.querySelectorAll(".app-view");
    const btnGotoLog = document.getElementById("btn-goto-log");

    // Dashboard View
    const statDays = document.getElementById("stat-days");
    const statLighthead = document.getElementById("stat-lighthead");
    const statHydration = document.getElementById("stat-hydration");
    const logsListContainer = document.getElementById("logs-list-container");

    // Log Form View
    const logForm = document.getElementById("log-form");
    const logDateInput = document.getElementById("log-date");
    const btnHKSync = document.getElementById("btn-hk-sync");
    const hkSyncBanner = document.getElementById("hk-sync-banner");
    const hkSyncedMetrics = document.getElementById("hk-synced-metrics");
    const btnSubmitLog = document.getElementById("btn-submit-log");

    // Form inputs
    const inputLightheadedness = document.getElementById("input-lightheadedness");
    const valLightheadedness = document.getElementById("val-lightheadedness");
    const inputTachyCount = document.getElementById("input-tachy-count");
    const groupTachySev = document.getElementById("group-tachy-sev");
    const inputTachySeverity = document.getElementById("input-tachy-severity");
    const valTachySeverity = document.getElementById("val-tachy-severity");
    const inputFatigue = document.getElementById("input-fatigue");
    const valFatigue = document.getElementById("val-fatigue");
    const inputBrainFog = document.getElementById("input-brainfog");
    const valBrainFog = document.getElementById("val-brainfog");
    const inputNausea = document.getElementById("input-nausea");
    const valNausea = document.getElementById("val-nausea");
    const inputSyncope = document.getElementById("input-syncope");
    const groupSyncopeCount = document.getElementById("group-syncope-count");
    const inputSyncopeCount = document.getElementById("input-syncope-count");

    const inputSleep = document.getElementById("input-sleep");
    const inputHydration = document.getElementById("input-hydration");
    const inputStanding = document.getElementById("input-standing");
    const inputMedication = document.getElementById("input-medication");
    const inputActivity = document.getElementById("input-activity");
    const inputMenstrualEnable = document.getElementById("input-menstrual-enable");
    const groupMenstrualDay = document.getElementById("group-menstrual-day");
    const inputMenstrualDay = document.getElementById("input-menstrual-day");
    const inputPressure = document.getElementById("input-pressure");
    const inputFood = document.getElementById("input-food");
    const inputNotes = document.getElementById("input-notes");

    // Patterns View
    const patternsThresholdGate = document.getElementById("patterns-threshold-gate");
    const progressCount = document.getElementById("progress-count");
    const progressCircleBar = document.getElementById("progress-circle-bar");
    const patternsPaywallGate = document.getElementById("patterns-paywall-gate");
    const btnPaywallUpgradePlans = document.getElementById("btn-paywall-upgrade-plans");
    const patternsPremiumContent = document.getElementById("patterns-premium-content");
    const btnPDFExport = document.getElementById("btn-pdf-export");
    const patternsListContainer = document.getElementById("patterns-list-container");
    const chartDetailsCard = document.getElementById("chart-details-card");
    const chartTitle = document.getElementById("chart-title");
    const correlationChartCanvas = document.getElementById("correlation-chart");

    // Settings View
    const settingsPremiumStatus = document.getElementById("settings-premium-status");
    const settingsPremiumDesc = document.getElementById("settings-premium-desc");
    const settingsBtnUpgrade = document.getElementById("settings-btn-upgrade");
    const settingsHKStatus = document.getElementById("settings-hk-status");
    const settingsBtnHKConnect = document.getElementById("settings-btn-hk-connect");
    const btnShowDisclaimer = document.getElementById("btn-show-disclaimer");

    // Developer settings
    const devPremiumToggle = document.getElementById("dev-premium-toggle");
    const devBtnGenerateLogs = document.getElementById("dev-btn-generate-logs");
    const devBtnClearLogs = document.getElementById("dev-btn-clear-logs");

    // --- ONBOARDING DISCLAIMER BLOCKER ---
    function checkDisclaimer() {
        if (!isDisclaimerAccepted) {
            disclaimerModal.classList.remove("hidden");
        } else {
            disclaimerModal.classList.add("hidden");
        }
    }
    
    btnAcceptDisclaimer.addEventListener("click", () => {
        isDisclaimerAccepted = true;
        localStorage.setItem("flarelog_disclaimer_accepted", "true");
        disclaimerModal.classList.add("hidden");
    });

    btnShowDisclaimer.addEventListener("click", () => {
        disclaimerModal.classList.remove("hidden");
    });

    // --- NAVIGATION LOGIC ---
    function switchView(viewId) {
        // Toggle tabs active class
        navTabs.forEach(tab => {
            if (tab.getAttribute("data-view") === viewId) {
                tab.classList.add("active");
            } else {
                tab.classList.remove("active");
            }
        });
        
        // Toggle views active class
        appViews.forEach(view => {
            if (view.id === viewId) {
                view.classList.add("active");
            } else {
                view.classList.remove("active");
            }
        });

        // Trigger view-specific rendering
        if (viewId === "view-dashboard") {
            renderDashboard();
        } else if (viewId === "view-patterns") {
            renderPatterns();
        } else if (viewId === "view-settings") {
            renderSettings();
        }
    }

    navTabs.forEach(tab => {
        tab.addEventListener("click", () => {
            const targetView = tab.getAttribute("data-view");
            switchView(targetView);
        });
    });

    // Quick log action from dashboard
    btnGotoLog.addEventListener("click", () => {
        resetForm();
        switchView("view-log");
    });

    // --- FORM INTERACTIVE STEPPERS AND SLIDERS ---
    // Sliders displays updating
    function setupSliderDisplay(sliderInput, badgeSpan) {
        sliderInput.addEventListener("input", () => {
            badgeSpan.textContent = `${sliderInput.value}/10`;
        });
    }

    setupSliderDisplay(inputLightheadedness, valLightheadedness);
    setupSliderDisplay(inputTachySeverity, valTachySeverity);
    setupSliderDisplay(inputFatigue, valFatigue);
    setupSliderDisplay(inputBrainFog, valBrainFog);
    setupSliderDisplay(inputNausea, valNausea);

    // Steppers logic
    document.querySelectorAll(".btn-step").forEach(btn => {
        btn.addEventListener("click", () => {
            const targetId = btn.getAttribute("data-id");
            const stepVal = parseFloat(btn.getAttribute("data-val"));
            const input = document.getElementById(targetId);
            
            let current = parseFloat(input.value) || 0;
            let newVal = current + stepVal;
            
            const min = parseFloat(input.getAttribute("min")) || 0;
            const max = parseFloat(input.getAttribute("max")) || 9999;
            
            newVal = Math.max(min, Math.min(max, newVal));
            input.value = input.step ? newVal.toFixed(parseFloat(input.step) === 0.25 ? 2 : 1) : newVal;

            // Trigger conditional inputs
            if (targetId === "input-tachy-count") {
                if (newVal > 0) {
                    groupTachySev.classList.remove("hidden");
                } else {
                    groupTachySev.classList.add("hidden");
                }
            }
        });
    });

    // Syncope conditional displays
    inputSyncope.addEventListener("change", () => {
        if (inputSyncope.checked) {
            groupSyncopeCount.classList.remove("hidden");
        } else {
            groupSyncopeCount.classList.add("hidden");
        }
    });

    // Menstrual cycle conditional displays
    inputMenstrualEnable.addEventListener("change", () => {
        if (inputMenstrualEnable.checked) {
            groupMenstrualDay.classList.remove("hidden");
        } else {
            groupMenstrualDay.classList.add("hidden");
        }
    });

    // --- MOCK HEALTHKIT CONNECTOR & PASSIVE SYNC ---
    btnHKSync.addEventListener("click", () => {
        if (!isHKConnected) {
            // Trigger HealthKit connect request
            isHKConnected = true;
            localStorage.setItem("flarelog_hk_connected", "true");
            renderSettings();
        }
        
        // Generate mock data for the selected date
        isSyncingHK(true);
        
        setTimeout(() => {
            // Simulated pull
            const randSteps = Math.floor(2500 + Math.random() * 6000);
            const randHR = Math.floor(66 + Math.random() * 15);
            const randHRV = Math.floor(35 + Math.random() * 30);
            const randSleep = Number((6.0 + Math.random() * 2.5).toFixed(1));
            
            currentFormHKData = {
                heartRateAverage: randHR,
                heartRateMin: randHR - 12,
                heartRateMax: randHR + 30,
                heartRateVariabilityAverage: randHRV,
                sleepDuration: randSleep,
                stepCount: randSteps
            };
            
            // Auto fill sleep habits duration
            inputSleep.value = randSleep;
            
            isSyncingHK(false);
            
            // Show Synced Banner
            hkSyncedMetrics.textContent = `${randSteps} steps, ${randHR} bpm avg HR, ${randHRV}ms HRV, ${randSleep}h sleep.`;
            hkSyncBanner.classList.remove("hidden");
        }, 800);
    });

    function isSyncingHK(syncing) {
        if (syncing) {
            btnHKSync.disabled = true;
            btnHKSync.innerHTML = `<span class="hk-icon">⏳</span> Syncing...`;
        } else {
            btnHKSync.disabled = false;
            btnHKSync.innerHTML = `<span class="hk-icon">❤️</span> Synced`;
            btnHKSync.style.borderColor = "var(--color-green)";
            btnHKSync.style.color = "var(--color-green)";
        }
    }

    // Connect HealthKit from Settings
    settingsBtnHKConnect.addEventListener("click", () => {
        if (isHKConnected) {
            isHKConnected = false;
            localStorage.setItem("flarelog_hk_connected", "false");
        } else {
            isHKConnected = true;
            localStorage.setItem("flarelog_hk_connected", "true");
        }
        renderSettings();
    });

    // --- PAYWALL LOGIC (PREMIUM EMULATOR) ---
    function updatePremiumVisuals() {
        if (isPremium) {
            premiumBadge.textContent = "PREMIUM";
            premiumBadge.classList.add("premium");
            devPremiumToggle.checked = true;
        } else {
            premiumBadge.textContent = "FREE TIER";
            premiumBadge.classList.remove("premium");
            devPremiumToggle.checked = false;
        }
    }

    function togglePaywall(show) {
        if (show) {
            paywallModal.classList.remove("hidden");
        } else {
            paywallModal.classList.add("hidden");
        }
    }

    btnPaywallUpgradePlans.addEventListener("click", () => togglePaywall(true));
    settingsBtnUpgrade.addEventListener("click", () => togglePaywall(true));
    btnClosePaywall.addEventListener("click", () => togglePaywall(false));

    btnSubscribe.addEventListener("click", () => {
        isPremium = true;
        localStorage.setItem("flarelog_premium", "true");
        updatePremiumVisuals();
        togglePaywall(false);
        renderSettings();
        renderPatterns();
    });

    btnRestore.addEventListener("click", () => {
        isPremium = true;
        localStorage.setItem("flarelog_premium", "true");
        updatePremiumVisuals();
        togglePaywall(false);
        renderSettings();
        renderPatterns();
    });

    // Dev settings premium toggle
    devPremiumToggle.addEventListener("change", () => {
        isPremium = devPremiumToggle.checked;
        localStorage.setItem("flarelog_premium", isPremium ? "true" : "false");
        updatePremiumVisuals();
        renderSettings();
        renderPatterns();
    });

    // --- FORM RESET & EDIT LOOPS ---
    function resetForm() {
        currentEditingId = null;
        currentFormHKData = null;
        hkSyncBanner.classList.add("hidden");
        
        // Form default values
        logDateInput.value = new Date().toISOString().substring(0, 10);
        btnHKSync.innerHTML = `<span class="hk-icon">❤️</span> Sync HealthKit`;
        btnHKSync.style.borderColor = "var(--border-color-glow)";
        btnHKSync.style.color = "var(--text-primary)";
        btnSubmitLog.textContent = "Save Journal Entry";

        // Reset inputs
        inputLightheadedness.value = 0; valLightheadedness.textContent = "0/10";
        inputTachyCount.value = 0; groupTachySev.classList.add("hidden");
        inputTachySeverity.value = 0; valTachySeverity.textContent = "0/10";
        inputFatigue.value = 0; valFatigue.textContent = "0/10";
        inputBrainFog.value = 0; valBrainFog.textContent = "0/10";
        inputNausea.value = 0; valNausea.textContent = "0/10";
        inputSyncope.checked = false; groupSyncopeCount.classList.add("hidden");
        inputSyncopeCount.value = 1;

        inputSleep.value = "7.0";
        inputHydration.value = "1.5";
        inputStanding.value = "20";
        inputMedication.checked = true;
        inputActivity.value = "light";
        inputMenstrualEnable.checked = false; groupMenstrualDay.classList.add("hidden");
        inputMenstrualDay.value = 1;
        inputPressure.value = "";
        inputFood.value = "";
        inputNotes.value = "";
    }

    function populateFormForEdit(log) {
        currentEditingId = log.id;
        currentFormHKData = log.healthKitPull;
        
        logDateInput.value = new Date(log.date).toISOString().substring(0, 10);
        btnSubmitLog.textContent = "Update Journal Entry";

        // Populate symptoms
        inputLightheadedness.value = log.symptoms.lightheadedness;
        valLightheadedness.textContent = `${log.symptoms.lightheadedness}/10`;
        
        inputTachyCount.value = log.symptoms.tachycardiaCount;
        if (log.symptoms.tachycardiaCount > 0) {
            groupTachySev.classList.remove("hidden");
            inputTachySeverity.value = log.symptoms.tachycardiaSeverity;
            valTachySeverity.textContent = `${log.symptoms.tachycardiaSeverity}/10`;
        } else {
            groupTachySev.classList.add("hidden");
        }
        
        inputFatigue.value = log.symptoms.fatigue;
        valFatigue.textContent = `${log.symptoms.fatigue}/10`;
        
        inputBrainFog.value = log.symptoms.brainFog;
        valBrainFog.textContent = `${log.symptoms.brainFog}/10`;
        
        inputNausea.value = log.symptoms.nausea;
        valNausea.textContent = `${log.symptoms.nausea}/10`;
        
        inputSyncope.checked = log.symptoms.syncopeExperienced;
        if (log.symptoms.syncopeExperienced) {
            groupSyncopeCount.classList.remove("hidden");
            inputSyncopeCount.value = log.symptoms.syncopeCount;
        } else {
            groupSyncopeCount.classList.add("hidden");
        }

        // Populate habits
        inputSleep.value = log.triggerCandidate.sleepHours || 7.0;
        inputHydration.value = log.triggerCandidate.hydrationLiters || 1.5;
        inputStanding.value = log.triggerCandidate.standingTimeMinutes || 20;
        inputMedication.checked = log.triggerCandidate.medicationTakenOnTime !== false;
        inputActivity.value = log.triggerCandidate.activityLevel || "light";
        
        if (log.triggerCandidate.menstrualCycleDay) {
            inputMenstrualEnable.checked = true;
            groupMenstrualDay.classList.remove("hidden");
            inputMenstrualDay.value = log.triggerCandidate.menstrualCycleDay;
        } else {
            inputMenstrualEnable.checked = false;
            groupMenstrualDay.classList.add("hidden");
        }
        
        inputPressure.value = log.triggerCandidate.weatherBarometricPressure || "";
        inputFood.value = log.triggerCandidate.foodNotes || "";
        inputNotes.value = log.notes || "";

        // Sync banner check
        if (log.healthKitPull && log.healthKitPull.heartRateAverage) {
            const h = log.healthKitPull;
            hkSyncedMetrics.textContent = `${h.stepCount} steps, ${h.heartRateAverage} bpm avg, ${h.heartRateVariabilityAverage}ms HRV, ${h.sleepDuration}h sleep.`;
            hkSyncBanner.classList.remove("hidden");
        } else {
            hkSyncBanner.classList.add("hidden");
        }
    }

    // Form Submission
    logForm.addEventListener("submit", (e) => {
        e.preventDefault();
        
        const dateStr = logDateInput.value;
        const entryDate = new Date(dateStr + "T00:00:00");
        
        const symptoms = {
            lightheadedness: parseInt(inputLightheadedness.value),
            tachycardiaCount: parseInt(inputTachyCount.value),
            tachycardiaSeverity: parseInt(inputTachyCount.value) > 0 ? parseInt(inputTachySeverity.value) : 0,
            fatigue: parseInt(inputFatigue.value),
            brainFog: parseInt(inputBrainFog.value),
            nausea: parseInt(inputNausea.value),
            syncopeExperienced: inputSyncope.checked,
            syncopeCount: inputSyncope.checked ? parseInt(inputSyncopeCount.value) : 0
        };
        
        const triggers = {
            foodNotes: inputFood.value.trim() || null,
            sleepHours: parseFloat(inputSleep.value),
            hydrationLiters: parseFloat(inputHydration.value),
            standingTimeMinutes: parseInt(inputStanding.value),
            medicationTakenOnTime: inputMedication.checked,
            menstrualCycleDay: inputMenstrualEnable.checked ? parseInt(inputMenstrualDay.value) : null,
            weatherBarometricPressure: inputPressure.value ? parseFloat(inputPressure.value) : null,
            activityLevel: inputActivity.value
        };

        const newLog = {
            id: currentEditingId || generateUUID(),
            date: entryDate.getTime(),
            notes: inputNotes.value.trim() || null,
            symptoms: symptoms,
            triggerCandidate: triggers,
            healthKitPull: currentFormHKData || {}
        };

        // Date boundary check: if this date already exists and we are not editing it, overwrite
        const normalizedDateTime = entryDate.getTime();
        const duplicateIndex = logs.findIndex(l => {
            const lDate = new Date(l.date);
            lDate.setHours(0,0,0,0);
            const checkDate = new Date(normalizedDateTime);
            checkDate.setHours(0,0,0,0);
            return lDate.getTime() === checkDate.getTime() && l.id !== newLog.id;
        });

        if (duplicateIndex !== -1) {
            // Overwrite existing log for this date
            newLog.id = logs[duplicateIndex].id;
            logs[duplicateIndex] = newLog;
        } else if (currentEditingId) {
            // Update current editing log
            const editIndex = logs.findIndex(l => l.id === currentEditingId);
            if (editIndex !== -1) {
                logs[editIndex] = newLog;
            }
        } else {
            // Save new log
            logs.push(newLog);
        }

        // Save state
        localStorage.setItem("flarelog_logs", JSON.stringify(logs));
        switchView("view-dashboard");
    });

    // Helper uuid
    function generateUUID() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }

    // --- VIEW 1: RENDER DASHBOARD ---
    function renderDashboard() {
        statDays.textContent = logs.length;
        
        // Averages
        const avgLight = logs.length === 0 ? 0.0 : logs.reduce((sum, l) => sum + (l.symptoms?.lightheadedness || 0), 0) / logs.length;
        statLighthead.textContent = avgLight.toFixed(1);

        const validHydration = logs.filter(l => l.triggerCandidate?.hydrationLiters !== undefined);
        const avgHydr = validHydration.length === 0 ? 0.0 : validHydration.reduce((sum, l) => sum + l.triggerCandidate.hydrationLiters, 0) / validHydration.length;
        statHydration.textContent = `${avgHydr.toFixed(1)}L`;

        // Clear list
        logsListContainer.innerHTML = "";

        if (logs.length === 0) {
            logsListContainer.innerHTML = `
                <div class="info-card" style="align-items: center; text-align: center; padding: 30px 20px;">
                    <span style="font-size: 32px; opacity: 0.3;">📄</span>
                    <strong>No journal entries yet</strong>
                    <p>Enter your first daily log to start tracking your POTS symptoms.</p>
                </div>
            `;
            return;
        }

        // Sort descending by date
        const sorted = [...logs].sort((a, b) => b.date - a.date);

        sorted.forEach(log => {
            const card = document.createElement("div");
            card.className = "log-card";
            
            // Format date
            const dateObj = new Date(log.date);
            const dateStr = dateObj.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' });

            // Symptom Chips HTML
            let chipsHtml = "";
            const s = log.symptoms;
            if (s.lightheadedness > 0) chipsHtml += `<span class="chip cyan">Lighthead: ${s.lightheadedness}</span>`;
            if (s.tachycardiaCount > 0) chipsHtml += `<span class="chip purple">Tachy: ${s.tachycardiaCount}x</span>`;
            if (s.fatigue > 0) chipsHtml += `<span class="chip orange">Fatigue: ${s.fatigue}</span>`;
            if (s.brainFog > 0) chipsHtml += `<span class="chip blue">Fog: ${s.brainFog}</span>`;
            if (s.nausea > 0) chipsHtml += `<span class="chip pink">Nausea: ${s.nausea}</span>`;
            if (s.syncopeExperienced) chipsHtml += `<span class="chip red">Syncope: ${s.syncopeCount}x</span>`;

            if (chipsHtml === "") {
                chipsHtml = `<span class="chip muted">No symptoms logged</span>`;
            }

            // Habits Summary line
            let habitsList = [];
            const t = log.triggerCandidate;
            if (t.sleepHours !== undefined) habitsList.push(`<span>🛏️ ${t.sleepHours}h sleep</span>`);
            if (t.hydrationLiters !== undefined) habitsList.push(`<span>💧 ${t.hydrationLiters}L</span>`);
            if (t.standingTimeMinutes !== undefined) habitsList.push(`<span>⏱️ ${t.standingTimeMinutes}m stand</span>`);
            
            const habitsSummaryHtml = habitsList.join("");

            // Notes snippet
            const notesHtml = log.notes ? `<div class="log-notes-snippet">${log.notes}</div>` : "";

            card.innerHTML = `
                <div class="log-card-header">
                    <span class="log-date-label">${dateStr}</span>
                    <button class="btn-delete-log" data-id="${log.id}">Delete</button>
                </div>
                <div class="log-chips-row">${chipsHtml}</div>
                <div class="log-habits-summary">${habitsSummaryHtml}</div>
                ${notesHtml}
            `;

            // Card click to edit
            card.addEventListener("click", (e) => {
                if (e.target.classList.contains("btn-delete-log")) return;
                populateFormForEdit(log);
                switchView("view-log");
            });

            // Delete click
            card.querySelector(".btn-delete-log").addEventListener("click", (e) => {
                e.stopPropagation();
                if (confirm("Delete this journal entry?")) {
                    logs = logs.filter(l => l.id !== log.id);
                    localStorage.setItem("flarelog_logs", JSON.stringify(logs));
                    renderDashboard();
                }
            });

            logsListContainer.appendChild(card);
        });
    }

    // --- VIEW 3: RENDER PATTERNS ---
    function renderPatterns() {
        selectedPatternId = null;
        chartDetailsCard.classList.add("hidden");
        
        if (logs.length < 14) {
            // Show threshold indicator gate
            patternsThresholdGate.classList.remove("hidden");
            patternsPaywallGate.classList.add("hidden");
            patternsPremiumContent.classList.add("hidden");
            
            progressCount.textContent = logs.length;
            
            // Set SVG stroke circle dashoffset
            const dashoffset = 251.2 - (251.2 * Math.min(logs.length, 14)) / 14;
            progressCircleBar.style.strokeDashoffset = dashoffset;
            return;
        }

        // Count is 14+, check premium status
        patternsThresholdGate.classList.add("hidden");
        
        if (!isPremium) {
            patternsPaywallGate.classList.remove("hidden");
            patternsPremiumContent.classList.add("hidden");
            return;
        }

        // Count is 14+ and Premium, render correlations
        patternsPaywallGate.classList.add("hidden");
        patternsPremiumContent.classList.remove("hidden");

        const patterns = window.CorrelationEngine.analyze(logs);
        const significant = patterns.filter(p => p.isSignificant);

        patternsListContainer.innerHTML = "";

        if (significant.length === 0) {
            patternsListContainer.innerHTML = `
                <div class="info-card" style="align-items: center; text-align: center; padding: 30px 20px;">
                    <span style="font-size: 32px; opacity: 0.3;">📈</span>
                    <strong>No patterns detected yet</strong>
                    <p>Our correlation engine found no statistically significant patterns in your entries yet. Keep logging to collect more data.</p>
                </div>
            `;
            return;
        }

        significant.forEach(pattern => {
            const card = document.createElement("div");
            card.className = "pattern-card";
            card.setAttribute("data-id", pattern.id);
            
            const directionClass = pattern.r > 0 ? "positive" : "negative";

            card.innerHTML = `
                <div class="pattern-card-header">
                    <span class="pattern-indicator ${directionClass}"></span>
                    <span class="pattern-title">${capitalize(pattern.trigger.displayName)} vs ${capitalize(pattern.symptom.displayName)}</span>
                </div>
                <p class="pattern-desc">${pattern.observationalSentence}</p>
                <div class="pattern-stats-row">
                    <span>Pearson r: ${pattern.r.toFixed(2)}</span>
                    <span>Adjusted p: ${pattern.adjustedPValue.toFixed(3)}</span>
                    <span>Sample: ${pattern.sampleSize} days</span>
                </div>
            `;

            card.addEventListener("click", () => {
                // Toggle select
                const previouslySelected = card.classList.contains("selected");
                
                document.querySelectorAll(".pattern-card").forEach(c => c.classList.remove("selected"));
                
                if (previouslySelected) {
                    selectedPatternId = null;
                    chartDetailsCard.classList.add("hidden");
                } else {
                    card.classList.add("selected");
                    selectedPatternId = pattern.id;
                    renderPatternChart(pattern);
                }
            });

            patternsListContainer.appendChild(card);
        });

        // Setup PDF Button
        btnPDFExport.onclick = () => {
            btnPDFExport.disabled = true;
            btnPDFExport.innerHTML = `⏳ Generating...`;
            
            setTimeout(() => {
                window.PDFGenerator.downloadPDF(logs, patterns);
                btnPDFExport.disabled = false;
                btnPDFExport.innerHTML = `📄 Export PDF`;
            }, 600);
        };
    }

    function capitalize(str) {
        return str.charAt(0).toUpperCase() + str.slice(1);
    }

    function renderPatternChart(pattern) {
        chartTitle.textContent = `Visualizing ${pattern.trigger.displayName} vs ${pattern.symptom.displayName}`;
        chartDetailsCard.classList.remove("hidden");

        // Fetch coordinates
        const chartData = [];
        for (const log of logs) {
            const x = pattern.trigger.extractor(log);
            const y = pattern.symptom.extractor(log);
            if (x !== undefined && x !== null && y !== undefined && y !== null) {
                chartData.push({ x: Number(x), y: Number(y) });
            }
        }

        // Reset chart instance
        if (chartInstance) {
            chartInstance.destroy();
        }

        const ctx = correlationChartCanvas.getContext("2d");
        chartInstance = new Chart(ctx, {
            type: 'scatter',
            data: {
                datasets: [{
                    label: 'Entries',
                    data: chartData,
                    backgroundColor: '#14b8a6',
                    borderColor: '#0ea5e9',
                    borderWidth: 1,
                    pointRadius: 6,
                    pointHoverRadius: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    x: {
                        type: 'linear',
                        position: 'bottom',
                        title: {
                            display: true,
                            text: capitalize(pattern.trigger.displayName) + (pattern.trigger.unit ? ` (${pattern.trigger.unit})` : ''),
                            color: '#94a3b8',
                            font: { family: 'Inter', weight: 600 }
                        },
                        grid: { color: 'rgba(255, 255, 255, 0.05)' },
                        ticks: { color: '#64748b' }
                    },
                    y: {
                        title: {
                            display: true,
                            text: capitalize(pattern.symptom.displayName) + (pattern.symptom.unit ? ` (${pattern.symptom.unit})` : ''),
                            color: '#94a3b8',
                            font: { family: 'Inter', weight: 600 }
                        },
                        grid: { color: 'rgba(255, 255, 255, 0.05)' },
                        ticks: { color: '#64748b' }
                    }
                }
            }
        });
    }

    // --- VIEW 4: RENDER SETTINGS ---
    function renderSettings() {
        updatePremiumVisuals();
        
        // Premium status UI
        if (isPremium) {
            settingsPremiumStatus.textContent = "Premium Subscriber Active";
            settingsPremiumDesc.textContent = "Full access to patterns & PDF export.";
            settingsBtnUpgrade.classList.add("hidden");
        } else {
            settingsPremiumStatus.textContent = "FlareLog Free";
            settingsPremiumDesc.textContent = "Correlation engine is locked.";
            settingsBtnUpgrade.classList.remove("hidden");
        }

        // HealthKit connectivity UI
        if (isHKConnected) {
            settingsHKStatus.textContent = "Active";
            settingsHKStatus.style.color = "var(--color-green)";
            settingsBtnHKConnect.textContent = "Disconnect";
        } else {
            settingsHKStatus.textContent = "Not connected";
            settingsHKStatus.style.color = "var(--text-muted)";
            settingsBtnHKConnect.textContent = "Connect";
        }
    }

    // --- DEVELOPER MOCK ACTIONS ---
    devBtnGenerateLogs.addEventListener("click", () => {
        // Generate 20 days of synthetic data
        const mockLogs = [];
        
        for (let i = 0; i < 20; i++) {
            const offsetDays = -i;
            const date = new Date();
            date.setDate(date.getDate() + offsetDays);
            date.setHours(0,0,0,0);
            
            // Sleep ranges from 5.0 to 9.0 hours
            const sleep = 5.0 + (i % 5);
            
            // Plant strong negative correlation between sleepHours and lightheadedness severity
            const baseLight = Math.floor(14.0 - sleep * 1.5);
            const noise = (i % 2 === 0) ? 1 : 0;
            const lightheadedness = Math.max(0, Math.min(10, baseLight + noise));
            
            // Standing time: 10 to 50 min
            const standTime = 10 + (i % 5) * 10;
            const tachyCount = Math.max(0, Math.floor((standTime - 10) / 10 + (i % 2)));
            const tachySeverity = tachyCount > 0 ? Math.max(1, Math.min(10, tachyCount * 2 - noise)) : 0;
            
            const symptoms = {
                lightheadedness: lightheadedness,
                tachycardiaCount: tachyCount,
                tachycardiaSeverity: tachySeverity,
                fatigue: Math.max(1, Math.min(10, Math.floor(8 - sleep / 2) + noise)),
                brainFog: Math.max(1, Math.min(10, Math.floor(9 - sleep / 1.8))),
                nausea: (i % 4 === 0) ? 3 : 0,
                syncopeExperienced: (i === 5 || i === 12),
                syncopeCount: (i === 5 || i === 12) ? 1 : 0
            };
            
            const triggers = {
                foodNotes: i % 3 === 0 ? "High sodium diet" : "Standard diet",
                sleepHours: sleep,
                hydrationLiters: 1.0 + (i % 4) * 0.5,
                standingTimeMinutes: standTime,
                medicationTakenOnTime: i % 8 !== 0,
                menstrualCycleDay: i % 28 + 1,
                weatherBarometricPressure: 1008.0 + (i % 10),
                activityLevel: i % 4 === 0 ? "rest" : (i % 4 === 1 ? "light" : (i % 4 === 2 ? "moderate" : "vigorous"))
            };
            
            const hk = {
                heartRateAverage: 72.0 + (tachyCount * 5),
                heartRateMin: 55.0,
                heartRateMax: 110.0 + (tachyCount * 10),
                heartRateVariabilityAverage: 45.0 + sleep * 3.0,
                sleepDuration: sleep - 0.2,
                stepCount: 2000 + standTime * 150
            };

            mockLogs.push({
                id: generateUUID(),
                date: date.getTime(),
                notes: `Synthetic log for testing day ${i + 1}`,
                symptoms: symptoms,
                triggerCandidate: triggers,
                healthKitPull: hk
            });
        }

        // Overwrite or append (overwrite makes it cleaner to view)
        logs = mockLogs;
        localStorage.setItem("flarelog_logs", JSON.stringify(logs));
        alert("Generated 20 days of correlated synthetic logs successfully!");
        
        switchView("view-dashboard");
    });

    devBtnClearLogs.addEventListener("click", () => {
        if (confirm("Are you sure you want to clear all log entries?")) {
            logs = [];
            localStorage.removeItem("flarelog_logs");
            switchView("view-dashboard");
        }
    });

    // --- ON STARTUP BOOT ---
    checkDisclaimer();
    updatePremiumVisuals();
    renderDashboard();
});
