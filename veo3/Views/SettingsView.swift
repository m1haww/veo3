import SwiftUI
import RevenueCat

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @ObservedObject private var appStateManager = AppStateManager.shared
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    if !subscriptionManager.isSubscribed {
                        VStack(spacing: 20) {
                            SettingsSectionHeader(title: "Subscription", icon: "crown.fill")
                            
                            Button(action: { appStateManager.presentPaywall() }) {
                                HStack {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.yellow)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Upgrade to Premium")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Text("Unlock all features")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color.purple.opacity(0.3), Color.pink.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                subscriptionManager.restorePurchases { success in
                                    if success, let customerInfo = subscriptionManager.customerInfo {
                                        if let activeSubscription = customerInfo.activeSubscriptions.first {
                                            let creditsToAdd = getCreditsForProduct(activeSubscription)
                                            subscriptionManager.addCredits(creditsToAdd)
                                        } else if let recentPurchase = customerInfo.allPurchasedProductIdentifiers.first {
                                            let creditsToAdd = getCreditsForProduct(recentPurchase)
                                            subscriptionManager.addCredits(creditsToAdd)
                                        }
                                    }
                                }
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 20))
                                        .foregroundColor(.blue)
                                        .frame(width: 30)
                                    
                                    Text("Restore Purchases")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    VStack(spacing: 20) {
                        SettingsSectionHeader(title: "About", icon: "info.circle.fill")
                        
                        SettingsInfoRow(
                            title: "Version",
                            value: "1.0.9",
                            icon: "app.badge",
                            iconColor: .cyan
                        )
                        
                        SettingsLinkRow(
                            title: "Privacy Policy",
                            icon: "lock.shield.fill",
                            iconColor: .purple,
                            action: { 
                                if let url = URL(string: "https://docs.google.com/document/d/1QP8Xk3Oh9QYw1ZD6M97dkeo63aA77Sppii3EC63PGZk/edit?usp=sharing") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )
                        
                        SettingsLinkRow(
                            title: "Terms of Service",
                            icon: "doc.text.fill",
                            iconColor: .blue,
                            action: { 
                                if let url = URL(string: "https://docs.google.com/document/d/1ZrNdg4W3Ug4BhokVc1BEgEAVmzWMykdalOpQvaZmm0A/edit?usp=sharing") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )
                        
                        SettingsLinkRow(
                            title: "Contact Support",
                            icon: "envelope.fill",
                            iconColor: .green,
                            action: { 
                                if let url = URL(string: "mailto:vekidotunize81459@gmail.com") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        Text("Made with ❤️ by Veo Team")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Text("© 2025 Veo. All rights reserved.")
                            .font(.system(size: 12))
                            .foregroundColor(.gray.opacity(0.6))
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.white)
            }
        }
    }
    
    private func getCreditsForProduct(_ productId: String) -> Int {
        switch productId {
        case "veo3.yearly.com":
            return 10
        case "veo3.monthly.com":
            return 50
        default:
            return 0
        }
    }
}

struct SettingsSectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.8))
            
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.top, 10)
    }
}

struct SettingsToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.purple)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct SettingsInfoRow: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 30)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct SettingsLinkRow: View {
    let title: String
    let icon: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
                    .frame(width: 30)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}
