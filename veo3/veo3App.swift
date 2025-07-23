import SwiftUI
import RevenueCat
import RevenueCatUI

@main
struct veo3App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if subscriptionManager.showOnboarding {
                    OnboardingView()
                } else {
                    ContentView()
                }
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        Purchases.logLevel = .info
        Purchases.configure(withAPIKey: Conts.shared.revenueCatApiKey)
        
        SubscriptionManager.shared.loadConfig()
        configureAppearance()
        
        Task {
            await loadBaseURL()
        }
        
        return true
    }
    
    private func loadBaseURL() async {
        do {
            let baseUrl = try await BackendService.shared.fetchBaseURL()
            print("[AppDelegate] Base URL loaded: \(baseUrl)")
        } catch {
            print("[AppDelegate] Failed to load base URL: \(error.localizedDescription)")
        }
    }
    
    private func configureAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.black
        
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 10)
        ]
        
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
