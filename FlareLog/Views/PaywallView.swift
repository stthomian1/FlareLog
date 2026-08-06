import SwiftUI
import StoreKit

public enum PlanTier: String, CaseIterable, Identifiable {
    case monthly
    case annual
    
    public var id: String { rawValue }
}

public struct PaywallView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Binding public var isPresented: Bool
    @State private var selectedTier: PlanTier = .annual
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    public var body: some View {
        ZStack {
            // Glowing background gradient
            Color(red: 0.06, green: 0.09, blue: 0.16)
                .ignoresSafeArea()
            
            // Subtle premium radial glow
            RadialGradient(
                colors: [Color.teal.opacity(0.15), Color.clear],
                center: .top,
                startRadius: 50,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header dismiss button
                HStack {
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Icon and title
                VStack(spacing: 6) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Text("FlareLog Premium")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Unlock the full statistical power of your logs.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                // Benefits List
                VStack(alignment: .leading, spacing: 14) {
                    BenefitRow(
                        title: "FDR Pattern Analysis",
                        description: "Reveal true statistical correlations between your triggers and symptoms, filtered against false discoveries.",
                        icon: "chart.line.uptrend.xyaxis"
                    )
                    
                    BenefitRow(
                        title: "Unlimited Log History",
                        description: "Keep records of your symptoms and habits beyond the 30-day free tier restriction.",
                        icon: "infinity"
                    )
                    
                    BenefitRow(
                        title: "PDF Reports for Doctors",
                        description: "Compile and export complete logs plus surfaced patterns to PDF to print or share at doctor visits.",
                        icon: "doc.richtext"
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.02))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
                .padding(.horizontal, 16)
                
                Spacer()
                
                // Subscription Options Cards
                VStack(spacing: 10) {
                    if let err = subscriptionManager.purchaseError {
                        Text(err)
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                    
                    // Prices loaded dynamically from StoreKit or fallbacks
                    let monthlyPrice = subscriptionManager.monthlyProduct?.displayPrice ?? "$4.99"
                    let annualPrice = subscriptionManager.annualProduct?.displayPrice ?? "$29.99"
                    
                    HStack(spacing: 12) {
                        // Annual Option Card
                        Button(action: { selectedTier = .annual }) {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("Annual")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("SAVE 50%")
                                        .font(.system(size: 9, weight: .black))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.yellow)
                                        .cornerRadius(4)
                                }
                                
                                Text("\(annualPrice) / yr")
                                    .font(.system(size: 18, weight: .black, design: .rounded))
                                    .foregroundColor(.teal)
                                
                                Text("~$2.50 / month")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(selectedTier == .annual ? Color.teal.opacity(0.15) : Color.white.opacity(0.03))
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(selectedTier == .annual ? Color.teal : Color.white.opacity(0.1), lineWidth: selectedTier == .annual ? 2 : 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Monthly Option Card
                        Button(action: { selectedTier = .monthly }) {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("Monthly")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                
                                Text("\(monthlyPrice) / mo")
                                    .font(.system(size: 18, weight: .black, design: .rounded))
                                    .foregroundColor(.teal)
                                
                                Text("Flexible billing")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(selectedTier == .monthly ? Color.teal.opacity(0.15) : Color.white.opacity(0.03))
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(selectedTier == .monthly ? Color.teal : Color.white.opacity(0.1), lineWidth: selectedTier == .monthly ? 2 : 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 16)
                    
                    Text("Auto-renews. Cancel anytime in App Store settings.")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.top, 2)
                    
                    // Purchase Button
                    Button(action: triggerPurchase) {
                        HStack {
                            if subscriptionManager.isPurchasing {
                                ProgressView()
                                    .tint(.black)
                            } else {
                                Text("Subscribe Now")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                            }
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.teal, Color(red: 0.1, green: 0.8, blue: 0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: .teal.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(subscriptionManager.isPurchasing)
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    
                    // Restore Button
                    Button(action: restorePurchases) {
                        Text("Restore Purchases")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.vertical, 4)
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    private func triggerPurchase() {
        Task {
            let targetProduct = selectedTier == .annual ? subscriptionManager.annualProduct : subscriptionManager.monthlyProduct
            let targetID = selectedTier == .annual ? SubscriptionManager.annualProductID : SubscriptionManager.monthlyProductID
            let success = await subscriptionManager.buySubscription(product: targetProduct, productID: targetID)
            if success {
                isPresented = false
            }
        }
    }
    
    private func restorePurchases() {
        Task {
            await subscriptionManager.restorePurchases()
            if subscriptionManager.isPremium {
                isPresented = false
            }
        }
    }
}

struct BenefitRow: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.teal)
                .frame(width: 24, height: 24)
                .background(Color.teal.opacity(0.1))
                .cornerRadius(6)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text(description)
                    .font(.system(size: 11.5))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
            }
        }
    }
}
