import Foundation
import RevenueCat
import SwiftUI

final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var isSubscribed = false
    @Published var customerInfo: CustomerInfo?
    @Published var credits: Int = 0
    @Published var showOnboarding = false
    
    private let creditsKey = "UserCredits"
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    func loadConfig() {
        loadCredits()
        checkSubscriptionStatus()
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
        showOnboarding = false
    }
    
    private func checkSubscriptionStatus() {
//        Purchases.shared.getCustomerInfo { (customerInfo, error) in
//            self.isSubscribed = customerInfo?.entitlements.all["Pro"]?.isActive == true
//        }
//        self.showOnboarding = !UserDefaults.standard.bool(forKey: "onboardingCompleted")
        self.isSubscribed = true
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
                self?.isSubscribed = !(customerInfo?.entitlements.active.isEmpty ?? true)
                completion(self?.isSubscribed ?? false)
            }
        }
    }
    
    func addCredits(_ amount: Int) {
        credits += amount
        saveCredits()
    }
    
    func useCredits(_ amount: Int) -> Bool {
        if credits >= amount {
            credits -= amount
            saveCredits()
            return true
        }
        return false
    }
    
    func hasCredits(_ amount: Int) -> Bool {
        return credits >= amount
    }
    
    private func saveCredits() {
        userDefaults.set(credits, forKey: creditsKey)
    }
    
    private func loadCredits() {
//        credits = userDefaults.integer(forKey: creditsKey)
        credits = 100
    }
}
