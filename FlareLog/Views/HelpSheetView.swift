import SwiftUI

public struct HelpSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Calm premium navy slate background matching the app theme
                Color(red: 0.06, green: 0.09, blue: 0.16)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Cozy Intro header
                        VStack(spacing: 8) {
                            Image(systemName: "questionmark.key.filled")
                                .font(.system(size: 48))
                                .foregroundColor(.teal)
                                .shadow(color: .teal.opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            Text("FlareLog Help Guide")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Everything you need to know about tracking your POTS.")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        .padding(.top, 10)
                        
                        // POTS Quick Explainer
                        VStack(alignment: .leading, spacing: 10) {
                            Text("What is POTS?")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.teal)
                            
                            Text("POTS (Postural Orthostatic Tachycardia Syndrome) is a fancy way of saying your body has a hard time adjusting when you stand up. When you go from lying down to standing, your heart rate jumps and you might feel dizzy or super tired. Tracking your daily habits helps you learn what triggers a flare-up so you can feel better!")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.85))
                                .lineSpacing(4)
                        }
                        .padding(.all, 14)
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.teal.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        
                        // Privacy Explainer
                        VStack(alignment: .leading, spacing: 10) {
                            Text("🔒 100% Private & Local")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.teal)
                            
                            Text("Every single piece of information you enter into FlareLog remains completely private. All your logs are stored safely right on your own local device. None of your logs, habits, or data is stored in the cloud or sent to any server.")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.85))
                                .lineSpacing(4)
                        }
                        .padding(.all, 14)
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.teal.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        
                        // Terms Section
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Symptom Definitions")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 12) {
                                DefinitionRow(
                                    term: "Dizziness / Lightheadedness",
                                    definition: "That woozy, spinning feeling you get when standing up or sitting for too long. It feels like you might faint.",
                                    icon: "brain",
                                    color: .cyan
                                )
                                
                                DefinitionRow(
                                    term: "Racing Heart (Tachycardia)",
                                    definition: "When your heart beats super fast or pounds heavily in your chest, even though you are just standing or resting.",
                                    icon: "heart.fill",
                                    color: .purple
                                )
                                
                                DefinitionRow(
                                    term: "Tiredness (Fatigue)",
                                    definition: "Feeling completely out of energy. It's that heavy, exhausted feeling that doesn't always go away with sleep.",
                                    icon: "battery.50",
                                    color: .orange
                                )
                                
                                DefinitionRow(
                                    term: "Brain Fog",
                                    definition: "When your head feels cloudy or fuzzy. It makes it hard to focus, think, do schoolwork, or remember things.",
                                    icon: "cloud.drizzle",
                                    color: .blue
                                )
                                
                                DefinitionRow(
                                    term: "Nausea",
                                    definition: "Feeling sick to your stomach, like you might throw up or just don't feel like eating.",
                                    icon: "thermometer",
                                    color: .pink
                                )
                                
                                DefinitionRow(
                                    term: "Fainting / Passing Out (Syncope)",
                                    definition: "Actually passing out (blacking out) or feeling like you were *just* about to collapse.",
                                    icon: "sparkles.tv",
                                    color: .red
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Habits Section
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Habit & Trigger Explanations")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 12) {
                                DefinitionRow(
                                    term: "Water Intake (Hydration)",
                                    definition: "Drinking plenty of fluids helps keep your blood volume up, which stops your heart from racing. We track this in ounces (oz) now. US doctors often recommend 64 to 100+ oz a day for POTS!",
                                    icon: "drop.fill",
                                    color: .blue
                                )
                                
                                DefinitionRow(
                                    term: "Sleep Time",
                                    definition: "How many hours of sleep you got last night. Lack of sleep is a super common trigger for POTS flare-ups.",
                                    icon: "bed.double.fill",
                                    color: .teal
                                )
                                
                                DefinitionRow(
                                    term: "Time Spent Standing",
                                    definition: "Total minutes you spent standing up today. Standing puts stress on your body, so keeping track of it helps you find your limits.",
                                    icon: "clock.fill",
                                    color: .yellow
                                )
                                
                                DefinitionRow(
                                    term: "Air Pressure (Barometer)",
                                    definition: "The weight of the atmosphere. Weather changes (like a storm rolling in) can drop air pressure and make POTS symptoms worse!",
                                    icon: "barometer",
                                    color: .gray
                                )
                                
                                DefinitionRow(
                                    term: "Period Cycle Day",
                                    definition: "Hormone drops during your monthly period cycle can trigger bad POTS flares. Log which day of your cycle you're on to see if there's a link.",
                                    icon: "calendar",
                                    color: .red
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Help & Terms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.teal)
                    .font(.system(size: 15, weight: .bold))
                }
            }
        }
    }
}

struct DefinitionRow: View {
    let term: String
    let definition: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.15))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(term)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Text(definition)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                    .lineSpacing(3)
            }
            Spacer()
        }
        .padding(.all, 12)
        .background(Color.white.opacity(0.02))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.04), lineWidth: 1)
        )
    }
}

#Preview {
    HelpSheetView()
}
