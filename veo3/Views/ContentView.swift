import SwiftUI
import RevenueCat
import RevenueCatUI

struct SizeClassPreferenceKey: PreferenceKey {
    static var defaultValue: UserInterfaceSizeClass? = nil
    
    static func reduce(value: inout UserInterfaceSizeClass?, nextValue: () -> UserInterfaceSizeClass?) {
        value = nextValue() ?? value
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showCreateScreen = false
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @ObservedObject private var appStateManager = AppStateManager.shared
    
    @State private var cachedSizeClass: UserInterfaceSizeClass = .compact

    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeScreen()
                    .environment(\.horizontalSizeClass, cachedSizeClass)
                    .tabItem {
                        VStack {
                            Image(systemName: "wand.and.stars.inverse")
                                .font(.system(size: 20))
                            Text("AI Video")
                                .font(.system(size: 12))
                        }
                    }
                    .tag(0)
                
                Color.clear
                        .background(
                            GeometryReader { _ in
                                Color.clear
                                    .preference(key: SizeClassPreferenceKey.self,
                                                value: Environment(\.horizontalSizeClass).wrappedValue)
                            }
                        )
                        .tabItem {}
                    .tag(2)
                
                GalleryScreen()
                    .environment(\.horizontalSizeClass, cachedSizeClass)
                    .tabItem {
                        VStack {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 20))
                            Text("Gallery")
                                .font(.system(size: 12))
                        }
                    }
                    .tag(1)
            }
            .accentColor(.white)
            .tabViewStyle(DefaultTabViewStyle())
            .onPreferenceChange(SizeClassPreferenceKey.self) { value in
                cachedSizeClass = value ?? .compact
            }
            .transformEnvironment(\.horizontalSizeClass) { sizeClass in
                sizeClass = .compact
            }
            
            VStack {
                Spacer()
                
                Button(action: {
                    showCreateScreen = true
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple, Color.pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .offset(y: -8)
                .frame(maxWidth: .infinity)
            }
        }
        .sheet(isPresented: $showCreateScreen) {
            TextToVideoScreen()
        }
        .fullScreenCover(isPresented: $appStateManager.showPaywall) {
            PaywallView()
                .onPurchaseCompleted { customerInfo in
                    subscriptionManager.isSubscribed = customerInfo.entitlements.all["Pro"]?.isActive == true
                    appStateManager.showPaywall = false
                    subscriptionManager.customerInfo = customerInfo
                    
                    if let activeSubscription = customerInfo.activeSubscriptions.first {
                        let creditsToAdd = getCreditsForProduct(activeSubscription)
                        subscriptionManager.addCredits(creditsToAdd)
                    } else if let recentPurchase = customerInfo.allPurchasedProductIdentifiers.first {
                        let creditsToAdd = getCreditsForProduct(recentPurchase)
                        subscriptionManager.addCredits(creditsToAdd)
                    }
                }
        }
    }
    
    private func getCreditsForProduct(_ productId: String) -> Int {
        switch productId {
        case "veo3.yearly.com":
            return 110
        case "veo3.weekly.com":
            return 15
        default:
            return 0
        }
    }
}
