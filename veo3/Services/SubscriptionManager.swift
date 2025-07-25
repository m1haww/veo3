import Foundation
import RevenueCat
import SwiftUI

final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var isSubscribed = false
    @Published var customerInfo: CustomerInfo?
    @Published var credits: Int = 0
    @Published var showOnboarding = false
    
    private init() {}
    
    func loadConfig() {
        checkSubscriptionStatus()
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
        showOnboarding = false
    }
    
    private func checkSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            DispatchQueue.main.async {
                let isActive = customerInfo?.entitlements.all["Pro"]?.isActive == true
                self.isSubscribed = isActive
            }
        }
        self.showOnboarding = !UserDefaults.standard.bool(forKey: "onboardingCompleted")
    }
    
    func restorePurchases(completion: @escaping (Bool) -> Void) {
        Purchases.shared.restorePurchases { [weak self] customerInfo, error in
            if let error = error {
                print("Error restoring purchases: \(error)")
                completion(false)
                return
            }
            
            DispatchQueue.main.async {
                self?.customerInfo = customerInfo
                let isActive = customerInfo?.entitlements.all["Pro"]?.isActive == true
                self?.isSubscribed = isActive
                completion(self?.isSubscribed ?? false)
            }
        }
    }
    
    func addCredits(_ amount: Int) {
        credits += amount
    }
    
    func useCredits(_ amount: Int) {
        credits -= amount
        
        Task {
            do {
                let response = try await UserService.shared.useCredits(amount)
                print(response.remaining_credits)
            } catch {
                print("Error using credits: \(error)")
            }
        }
    }
    
    func hasCredits(_ amount: Int) -> Bool {
        return credits >= amount
    }
    
    func registerUser(credits: Int) async {
        do {
            let response = try await UserService.shared.registerUser(initialCredits: credits)
            print("User registered successfully.")
            print(response.credits)
        } catch {
            print("Error registering user: \(error)")
        }
    }
    
    func updateSubscriptionStatus(_ customerInfo: CustomerInfo) {
        let isActive = customerInfo.entitlements.all["Pro"]?.isActive == true
        isSubscribed = isActive
        self.customerInfo = customerInfo
        
        if isActive {
            if let activeSubscription = customerInfo.activeSubscriptions.first {
                let creditsToAdd = getCreditsForProduct(activeSubscription)
                addCredits(creditsToAdd)
                
                Task {
                    await registerUser(credits: creditsToAdd)
                }
            } else if let recentPurchase = customerInfo.allPurchasedProductIdentifiers.first {
                let creditsToAdd = getCreditsForProduct(recentPurchase)
                addCredits(creditsToAdd)
                
                Task {
                    await registerUser(credits: creditsToAdd)
                }
            }
        }
    }
    
    private func getCreditsForProduct(_ productId: String) -> Int {
        switch productId {
        case "com.vemix.weekly":
            return 10
        case "com.vemix.yearly":
            return 60
        default:
            return 0
        }
    }
}
