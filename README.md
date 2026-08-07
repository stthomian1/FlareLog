# FlareLog — POTS Wellness Journal & Pattern Finder

FlareLog is a premium, mobile-first wellness journaling app designed specifically for POTS (Postural Orthostatic Tachycardia Syndrome) patients. It enables users to log symptoms and daily habits in under 60 seconds, passively pull metrics from Apple HealthKit, and observe mathematically rigorous statistical patterns between variables—all stored local-only for maximum privacy.

---

## ⚠️ Important Medical Disclaimer
**FlareLog is a personal tracking journal. It is not a diagnostic tool, does not recommend treatments, medication alterations, or activity restrictions, and is not a medical device. Always seek professional clinical advice from a physician for medical decisions.**

---

## 📱 Dual-Architecture Overview

To accommodate different testing environments, FlareLog has been built with a dual-architecture:

1. **Responsive Web PWA (`web/`):** A standalone, client-side Progressive Web App (HTML5, CSS3, ES6 JavaScript) that runs in any mobile or desktop browser. Includes mock HealthKit data syncs, local storage database persistence, **Chart.js** correlation graphs, and **jsPDF** report downloads.
2. **Native iOS App (`FlareLog/` & `FlareLogCore/`):** A native SwiftUI iOS 16+ application utilizing **SwiftData** storage (encrypted at rest), Apple **HealthKit**, **PDFKit**, and **StoreKit 2** subscription billing.

---

## 📈 The Statistical Correlation Engine

Both the Web PWA and native iOS codebases share the same statistical calculations:

1. **Threshold Guard:** Excludes any correlation pair from analysis until at least **14 days of paired observations** exist.
2. **Pearson Correlation ($r$):** Calculates the linear relationship coefficient between candidate triggers ($X$) and symptom severities ($Y$).
3. **Student's $t$ Significance test:** Computes raw p-values using a two-tailed $t$-distribution derived from the Wallace and normal CDF error function (`erf`) approximations to test statistical significance.
4. **Benjamini-Hochberg (BH) FDR Correction:** Adjusts p-values to control the False Discovery Rate across all compared variables ($8\text{ triggers} \times 7\text{ symptoms} = 56\text{ hypotheses}$):
   $$q_{(i)} = \min \left[ 1.0, \min_{j \ge i} \left( P_{(j)} \frac{M}{j} \right) \right]$$
   Only correlations with an adjusted p-value $q \le 0.05$ are flagged as valid patterns.
5. **Observational Framing:** Employs strictly observational, non-causal descriptions for findings (e.g., *"On days you logged under 6 hours of sleep, your fatigue severity was higher in 8 of 10 entries. Log more days to confirm this pattern."*).

---

## 🚀 How to Run and Deploy

### Option A: The Web App / PWA (Easiest for Remote Testing)
The web app is deployed and hosted on GitHub Pages. Testers can visit:
👉 **[https://stthomian1.github.io/FlareLog/web/](https://stthomian1.github.io/FlareLog/web/)**

* **Install to Phone:** Open the link in Safari on an iPhone, tap **Share**, and select **Add to Home Screen** to run it full-screen without browser UI frames.

### Option B: Build the Native iOS App (Xcode)
1. Open the `FlareLog.xcodeproj` project folder in **Xcode 15+** on a compatible Mac.
2. Select an iOS 17+ Simulator or a physical test device.
3. Build and Run (**Cmd + R**).

---

## ⚙️ How to Test (Developer Tools)

To make testing easy, both versions include a **Developer Tools** section in Settings:
- **Mock Premium Status:** Toggle subscription locks on/off to bypass StoreKit blocks.
- **Generate 20 Days of Synthetic Logs:** Instantly populates 20 daily entries seeded with realistic, correlated tracking values (e.g., low sleep hours strongly correlated with high lightheadedness severity).
- **Reset Logs:** Wipes local database logs to test empty states.


---

## 📬 Support

For questions, issues, or help using FlareLog, please contact: geraldbryanjr@gmail.com

You can also open an issue in this repository.


---

## 🔒 Privacy Policy

_Last updated: August 2026_

FlareLog is designed to be private by default.

**Data collection and storage**
FlareLog does not require an account or login. All symptom logs, journal entries, and habit data you enter are stored locally on your device only. FlareLog does not operate a server or cloud backend, and your personal tracking data is never transmitted to or stored by us.

**HealthKit**
If you choose to connect Apple HealthKit, FlareLog reads relevant health metrics (such as heart rate) with your explicit permission, solely to display alongside your own logs on your device. This data is never uploaded, shared, or sold.

**Optional weather data**
FlareLog may optionally fetch local weather conditions to help you spot patterns between weather and symptoms. This request only includes an approximate location needed for the lookup and is not linked to your identity or stored on any server we control.

**No ads, analytics, or third-party tracking**
FlareLog does not include advertising, third-party analytics, or tracking SDKs, and does not sell or share your data with third parties.

**Your control over your data**
Because all data stays on your device, you can delete your data at any time by deleting entries in the app or uninstalling the app.

**Contact**
If you have questions about this privacy policy, contact geraldbryanjr@gmail.com.
