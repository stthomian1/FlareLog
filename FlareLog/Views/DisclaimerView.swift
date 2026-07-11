import SwiftUI

public struct DisclaimerView: View {
    @Binding public var isPresented: Bool
    @AppStorage("hasShownDisclaimer") private var hasShownDisclaimer: Bool = false
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    public var body: some View {
        ZStack {
            // Calm premium navy slate background
            Color(red: 0.06, green: 0.09, blue: 0.16)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Calm, medical-related header icon
                Image(systemName: "exclamationmark.shield.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.orange)
                    .padding(.top, 40)
                    .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Text("Medical Disclaimer")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Please read this disclaimer carefully before using FlareLog.")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        Text("• Not a Medical Device")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.orange)
                        + Text("\nFlareLog is a personal wellness tracking journal. It is not a diagnostic tool, does not suggest medication changes or treatment plans, does not recommend activity limits, and is not a medical device.")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.85))
                        
                        Text("• Personal Reference Only")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.orange)
                        + Text("\nAll content, statistics, and observations generated in this app are derived mathematically from data you enter. They are for informational purposes only, to help you identify statistical patterns in your own journal records.")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.85))
                        
                        Text("• Consult Your Doctor")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.orange)
                        + Text("\nThis app is not a substitute for clinical advice. You should always discuss your symptoms, logs, and any statistical findings with a qualified physician or doctor. Never disregard or delay seeking medical help due to information tracked in this app.")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.03))
                .cornerRadius(12)
                .padding(.horizontal, 16)
                
                Spacer()
                
                // Confirm agreement
                Button(action: {
                    hasShownDisclaimer = true
                    isPresented = false
                }) {
                    Text("I Understand & Agree")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.orange, Color(red: 1.0, green: 0.6, blue: 0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: .orange.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
}
