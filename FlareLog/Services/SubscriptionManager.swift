import Foundation
import StoreKit

@MainActor
public final class SubscriptionManager: ObservableObject {
    @Published public var isPremium: Bool = false
    @Published public var availableProducts: [Product] = []
    @Published public var purchaseError: String? = nil
    @Published public var isPurchasing: Bool = false
    
    public static let monthlyProductID = "com.stthomian1.FlareLog.premium.monthly"
    public static let annualProductID = "com.stthomian1.FlareLog.premium.annual"
    public static let allProductIDs: Set<String> = [monthlyProductID, annualProductID]
    
    public var monthlyProduct: Product? {
        availableProducts.first(where: { $0.id == Self.monthlyProductID })
    }
    
    public var annualProduct: Product? {
        availableProducts.first(where: { $0.id == Self.annualProductID })
    }
    
    private var transactionListener: Task<Void, Error>? = nil
    
    public init() {
        // Listen for transaction updates in background
        transactionListener = Task {
            for await result in Transaction.updates {
                await handleTransactionUpdate(result)
            }
        }
        
        Task {
            await checkCurrentEntitlements()
            await fetchProducts()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    public func fetchProducts() async {
        do {
            let products = try await Product.products(for: Self.allProductIDs)
            self.availableProducts = products
        } catch {
            self.purchaseError = "Failed to load StoreKit products: \(error.localizedDescription)"
        }
    }
    
    public func checkCurrentEntitlements() async {
        var foundPremium = false
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if Self.allProductIDs.contains(transaction.productID) {
                if transaction.revocationDate == nil {
                    // Check expiration if available
                    if let expirationDate = transaction.expirationDate {
                        if expirationDate > Date() {
                            foundPremium = true
                        }
                    } else {
                        // Non-expiring product or valid duration
                        foundPremium = true
                    }
                }
            }
        }
        
        if foundPremium {
            self.isPremium = true
        } else {
            // Check debug mock fallback
            self.isPremium = UserDefaults.standard.bool(forKey: "isPremiumDebugMock")
        }
    }
    
    public func buySubscription(product: Product? = nil, productID: String? = nil) async -> Bool {
        self.isPurchasing = true
        self.purchaseError = nil
        
        // Find target product from parameter or productID string
        let targetProduct = product ?? availableProducts.first(where: { $0.id == (productID ?? Self.monthlyProductID) })
        
        guard let productToBuy = targetProduct else {
            // If products array is empty (e.g. local debug without StoreKit setup), enable mock state
            self.isPremium = true
            UserDefaults.standard.set(true, forKey: "isPremiumDebugMock")
            self.isPurchasing = false
            return true
        }
        
        do {
            let result = try await productToBuy.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await checkCurrentEntitlements()
                    await transaction.finish()
                    self.isPurchasing = false
                    return true
                case .unverified(_, _):
                    self.purchaseError = "Transaction verification failed."
                    self.isPurchasing = false
                    return false
                }
            case .pending:
                self.purchaseError = "Purchase is pending authorization."
                self.isPurchasing = false
                return false
            case .userCancelled:
                self.purchaseError = nil
                self.isPurchasing = false
                return false
            @unknown default:
                self.isPurchasing = false
                return false
            }
        } catch {
            self.purchaseError = "Purchase failed: \(error.localizedDescription)"
            self.isPurchasing = false
            return false
        }
    }
    
    public func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkCurrentEntitlements()
        } catch {
            self.purchaseError = "Failed to sync App Store: \(error.localizedDescription)"
        }
    }
    
    private func handleTransactionUpdate(_ result: VerificationResult<Transaction>) async {
        await checkCurrentEntitlements()
    }
    
    // Toggle function to bypass paywall in Simulator/VM
    public func togglePremiumDebug() {
        self.isPremium.toggle()
        UserDefaults.standard.set(self.isPremium, forKey: "isPremiumDebugMock")
    }
}
