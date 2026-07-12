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
                
                Text("Safety Warning & Agreement")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Please read this safety warning carefully before using FlareLog.")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        Text("• This App is Not a Doctor")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.orange)
                        + Text("\nFlareLog is just a personal daily journal to track how you feel. It cannot tell you what medical condition you have, tell you to change your meds or treatments, suggest limits on what you do, or act like a medical device.")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.85))
                        
                        Text("• For Your Own Info Only")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.orange)
                        + Text("\nAll the charts, stats, and patterns you see in this app are just math based on what you type in. They are only meant to help you spot trends in your own daily logs.")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.85))
                        
                        Text("• Always Talk to Your Doctor")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.orange)
                        + Text("\nThis app does not replace a real doctor. You should always talk about your symptoms, logs, and what you find in the app with your doctor or physician. Never ignore or delay getting medical help because of what you see here.")
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
