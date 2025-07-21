import SwiftUI

struct OnboardingPage {
    let title: String
    let description: String
    let videoName: String
    let gradient: [Color]
    let accentColor: Color
}

struct OnboardingView: View {
    @State private var currentPage = 0
    
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @ObservedObject private var appState = AppStateManager.shared
    
    let onboardingPages = [
        OnboardingPage(
            title: "Text to Video",
            description: "Turn your ideas into eye-catching videos. Just type a prompt and watch AI craft stunning visuals with rich details, audio, and flexible resolution options.",
            videoName: "onboarding1",
            gradient: [Color.purple, Color.pink],
            accentColor: Color.purple
        ),
        OnboardingPage(
            title: "Image to Video",
            description: "Upload an image and let AI bring it to life. Automatically add sound, smooth animation, and cinematic flair with zero editing required.",
            videoName: "onboarding2",
            gradient: [Color.blue, Color.cyan],
            accentColor: Color.blue
        ),
        OnboardingPage(
            title: "Professional Quality",
            description: "Create high-impact videos that look like they were made by a pro. Perfect for social media, marketing, or storytelling—powered by advanced AI.",
            videoName: "onboarding3",
            gradient: [Color.orange, Color.yellow],
            accentColor: Color.orange
        )
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    FullWidthVideoPlayer(videoName: onboardingPages[currentPage].videoName)
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.85)
                        .clipped()
                    
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0),
                            Color.black.opacity(0.3),
                            Color.black.opacity(0.7),
                            Color.black.opacity(0.9),
                            Color.black
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 150)
                }
                .frame(height: UIScreen.main.bounds.height * 0.5)
                
                VStack(alignment: .leading, spacing: 20) {
                    Spacer()
                    
                    Text(onboardingPages[currentPage].title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 30)
                        .padding(.horizontal, 20)
                    
                    Text(onboardingPages[currentPage].description)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 20)
                        .lineLimit(4)
                        .padding(.bottom, 30)
                    
                    HStack(spacing: 13) {
                        Spacer()
                        
                        ForEach(0..<onboardingPages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 13, height: 13)
                                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentPage)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 13)
                    
                    Button(action: {
                        if currentPage < onboardingPages.count - 1 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        } else {
                            subscriptionManager.completeOnboarding()
                            withAnimation(.easeInOut(duration: 0.3)) {
                                appState.showPaywall = true
                            }
                        }
                    }) {
                        Text(currentPage == onboardingPages.count - 1 ? "Get Started" : "Continue")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color(red: 1, green: 0.85, blue: 0.4))
                            )
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .ignoresSafeArea(edges: .top)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -50 && currentPage < onboardingPages.count - 1 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage += 1
                        }
                    } else if value.translation.width > 50 && currentPage > 0 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage -= 1
                        }
                    }
                }
        )
        .background(Color.black)
    }
}
