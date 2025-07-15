//
//  veo3App.swift
//  veo3
//
//  Created by Mihail Ozun on 10.07.2025.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

@main
struct veo3App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showOnboarding = true
    @State private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if showOnboarding && !hasCompletedOnboarding && !subscriptionManager.isSubscribed {
                    OnboardingView()
                        .onAppear {
                            // Check if user has seen onboarding before
                            if UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
                                hasCompletedOnboarding = true
                                showOnboarding = false
                            }
                        }
                        .onDisappear {
                            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                            hasCompletedOnboarding = true
                            showOnboarding = false
                        }
                } else {
                    ContentView()
                        .environmentObject(subscriptionManager)
                }
            }
        }
    }
    
    private func getCreditsForProduct(_ productId: String) -> Int {
        switch productId {
        case "com.yourapp.credits_10":
            return 10
        case "com.yourapp.credits_50":
            return 50
        case "com.yourapp.credits_100":
            return 100
        case "com.yourapp.pro_monthly":
            return 50  // Monthly subscription gives 50 credits
        case "com.yourapp.pro_yearly":
            return 500 // Yearly subscription gives 500 credits
        default:
            return 20  // Default credits for any purchase
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        configureAppearance()
        
        // Configure RevenueCat
        Purchases.logLevel = .info
        Purchases.configure(withAPIKey: Conts.shared.revenueCatApiKey)
        
        return true
    }
    
    private func configureAppearance() {
        // Tab Bar Appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.black // Pure black background
        
        // Selected state
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 10)
        ]
        
        // Normal state
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(white: 0.5, alpha: 1.0)
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(white: 0.5, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 10)
        ]
        
        // Remove tab bar border
        tabBarAppearance.shadowImage = UIImage()
        tabBarAppearance.shadowColor = .clear
        
        // Apply appearance
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        
        // Navigation Bar Appearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = UIColor.black
        navigationBarAppearance.shadowColor = nil
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().tintColor = .white
    }
}
