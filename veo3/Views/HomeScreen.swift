import SwiftUI
import AVKit

struct HomeScreen: View {
    @State private var showingSettings = false
    @State private var showingTextToVideo = false
    @StateObject private var appState = AppStateManager.shared
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ZStack(alignment: .top) {
                            ZStack {
                                FullWidthVideoPlayer(videoName: "skydive")
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width, height: 300)
                                    .clipped()
                                
                                VStack {
                                    Spacer()
                                    LinearGradient(
                                        colors: [
                                            Color.black.opacity(0),
                                            Color.black.opacity(0.2),
                                            Color.black.opacity(0.5),
                                            Color.black.opacity(0.8),
                                            Color.black.opacity(0.95),
                                            Color.black
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .frame(height: 100)
                                }
                                .frame(width: UIScreen.main.bounds.width, height: 300)
                                
                                VStack(spacing: 7) {
                                    Spacer()
                                    
                                    Text("AI Skydive")
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                                    
                                    Button(action: {
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                        impactFeedback.impactOccurred()
                                        
                                        appState.setPromptText("A thrilling skydiving adventure through clouds with an epic aerial view, extreme sports action sequence with professional camera work, cinematic lighting and dynamic movement")
                                        showingTextToVideo = true
                                    }) {
                                        Text("Go for it!")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 50)
                                            .padding(.vertical, 12)
                                            .background(
                                                Capsule()
                                                    .fill(Color.white)
                                            )
                                    }
                                    .padding(.bottom, 5)
                                }
                            }
                            
                            VStack {
                                HStack {
                                    Button(action: { showingSettings = true }) {
                                        HStack(spacing: 5) {
                                            Image(systemName: "gearshape.fill")
                                                .font(.system(size: 17))
                                            Text("Settings")
                                                .font(.system(size: 15, weight: .medium))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(Color.black.opacity(0.4))
                                        .cornerRadius(20)
                                        .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 2)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        if !subscriptionManager.isSubscribed {
                                            appState.showPaywall = true
                                        }
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "film")
                                                .font(.system(size: 18))
                                            Text("\(subscriptionManager.credits)")
                                                .font(.system(size: 18, weight: .bold))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(Color.black.opacity(0.5))
                                        .cornerRadius(22)
                                        .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 2)
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.top, 60)
                                
                                Spacer()
                            }
                        }
                        
                        Button(action: { showingTextToVideo = true }) {
                            HStack {
                                Image(systemName: "pencil.line")
                                    .font(.system(size: 20))
                                Text("Create video with a few words")
                                    .font(.system(size: 16, weight: .medium))
                                Spacer()
                                Text("ABC")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .colorMultiply(Color(red: 0.8, green: 0.6, blue: 1))
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.yellow, .green, .blue, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 25)
                        
                        ForEach(VideoCategory.categories) { category in
                            VStack(alignment: .leading, spacing: 12) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(category.title)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text(category.subtitle)
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 16) {
                                        ForEach(Array(category.videos.enumerated()), id: \.offset) { index, video in
                                            LazyVideoThumbnailCard(
                                                videoName: video.fileName,
                                                title: video.displayTitle,
                                                isPortrait: category.isPortrait,
                                                category: category
                                            )
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSettings) {
                NavigationView {
                    SettingsView()
                }
            }
            .sheet(isPresented: $showingTextToVideo) {
                TextToVideoScreen()
            }
            .onChange(of: appState.shouldNavigateToCreate) { newValue in
                if newValue && appState.selectedVideoPreset != nil {
                    showingTextToVideo = true
                    appState.shouldNavigateToCreate = false
                }
            }
        }
    }
    
    struct VideoStyleCard: View {
        let title: String
        let backgroundImage: String
        
        var body: some View {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 140)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [Color.black.opacity(0.7), Color.black.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(12)
            }
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }
}

struct LazyVideoThumbnailCard: View {
    let videoName: String
    let title: String
    var isPortrait: Bool
    var category: VideoCategory?
    
    var body: some View {
        TimelineView(.animation) { _ in
            VideoThumbnailCard(
                videoName: videoName,
                title: title,
                isPortrait: isPortrait,
                category: category
            )
        }
    }
}
