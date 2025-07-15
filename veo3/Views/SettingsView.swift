import SwiftUI
import RevenueCat

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var notificationsEnabled = true
    @State private var autoplayEnabled = true
    @State private var hdQualityEnabled = false
    @State private var apiKey = ""
    @State private var showingAPIKeyAlert = false
    @ObservedObject private var appStateManager = AppStateManager.shared
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Subscription Section
                    VStack(spacing: 20) {
                        SettingsSectionHeader(title: "Subscription", icon: "crown.fill")
                        
                        if subscriptionManager.isSubscribed {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.green)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Premium Member")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Text("All features unlocked")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.2), Color.pink.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(12)
                        } else {
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
                        }
                        
                        Button(action: {
                            subscriptionManager.restorePurchases { success in
                                // Handle restore result
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
                    
                    VStack(spacing: 20) {
                        SettingsSectionHeader(title: "General", icon: "gear")
                        
                        SettingsToggleRow(
                            title: "Notifications",
                            subtitle: "Get updates about your video generation",
                            icon: "bell.fill",
                            iconColor: .purple,
                            isOn: $notificationsEnabled
                        )
                        
                        SettingsToggleRow(
                            title: "Autoplay Videos",
                            subtitle: "Automatically play videos in feed",
                            icon: "play.circle.fill",
                            iconColor: .blue,
                            isOn: $autoplayEnabled
                        )
                        
                        SettingsToggleRow(
                            title: "HD Quality",
                            subtitle: "Generate videos in highest quality",
                            icon: "sparkles",
                            iconColor: .orange,
                            isOn: $hdQualityEnabled
                        )
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 20) {
                        SettingsSectionHeader(title: "API Configuration", icon: "key.fill")
                        
                        Button(action: { showingAPIKeyAlert = true }) {
                            HStack {
                                Image(systemName: "key.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.green)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Runway API Key")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Text(apiKey.isEmpty ? "Not configured" : "••••••••")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                
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
                    .padding(.horizontal)
                    
                    VStack(spacing: 20) {
                        SettingsSectionHeader(title: "About", icon: "info.circle.fill")
                        
                        SettingsInfoRow(
                            title: "Version",
                            value: "1.0.0",
                            icon: "app.badge",
                            iconColor: .cyan
                        )
                        
                        SettingsLinkRow(
                            title: "Privacy Policy",
                            icon: "lock.shield.fill",
                            iconColor: .purple,
                            action: { }
                        )
                        
                        SettingsLinkRow(
                            title: "Terms of Service",
                            icon: "doc.text.fill",
                            iconColor: .blue,
                            action: { }
                        )
                        
                        SettingsLinkRow(
                            title: "Contact Support",
                            icon: "envelope.fill",
                            iconColor: .green,
                            action: { }
                        )
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        Text("Made with ❤️ by Veo Team")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Text("© 2024 Veo. All rights reserved.")
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
        .alert("API Key", isPresented: $showingAPIKeyAlert) {
            TextField("Enter your Runway API key", text: $apiKey)
            Button("Save") {
                // Save API key
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter your Runway API key to enable video generation")
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
