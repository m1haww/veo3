import SwiftUI
import AVKit

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showPaywall = false
    @State private var animationOffset: CGFloat = 0
    @State private var particleAnimation = false
    @State private var iconRotation: Double = 0
    @State private var iconScale: CGFloat = 1.0
    @State private var backgroundAnimation = false
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    
    let onboardingPages = [
        OnboardingPage(
            title: "Create Amazing AI Videos",
            description: "Transform your ideas into stunning videos with the power of artificial intelligence",
            videoNames: ["fantasy1", "fantasy2", "fantasy3"],
            gradient: [Color.purple, Color.pink],
            accentColor: Color.purple
        ),
        OnboardingPage(
            title: "Multiple AI Models",
            description: "Choose from various AI models to create the perfect video for your needs",
            videoNames: ["sirena1", "sirena2", "sirena3"],
            gradient: [Color.blue, Color.cyan],
            accentColor: Color.blue
        ),
        OnboardingPage(
            title: "Professional Quality",
            description: "Generate high-quality videos suitable for social media, marketing, and more",
            videoNames: ["girl1", "girl2", "girl3"],
            gradient: [Color.orange, Color.yellow],
            accentColor: Color.orange
        )
    ]
    
    var body: some View {
        ZStack {
            AnimatedBackground(currentPage: currentPage, pages: onboardingPages)
            
            EnhancedParticleSystem(isActive: particleAnimation, color: onboardingPages[currentPage].accentColor, particleCount: 60)
            
            VStack(spacing: 40) {
                Spacer()
                
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        OnboardingPageView(
                            page: onboardingPages[index],
                            isActive: currentPage == index
                        )
                        .tag(index)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 600)
                .onChange(of: currentPage) { _ in
                    triggerPageAnimation()
                }
                
                AnimatedPageIndicator(currentPage: currentPage, totalPages: onboardingPages.count)
                
                Spacer()
                
                VStack(spacing: 20) {
                    if currentPage < onboardingPages.count - 1 {
                        JuicyButton(
                            title: "Continue",
                            gradient: onboardingPages[currentPage].gradient,
                            action: {
                                withAnimation(.easeInOut(duration: 1.2)) {
                                    currentPage += 1
                                }
                            }
                        )
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                showPaywall = true
                            }
                        }) {
                            Text("Skip")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .opacity(0.7)
                        .scaleEffect(0.9)
                        .frame(height: 20)
                    } else {
                        JuicyButton(
                            title: "Continue",
                            gradient: onboardingPages[currentPage].gradient,
                            action: {
                                withAnimation(.easeInOut(duration: 1.0)) {
                                    showPaywall = true
                                }
                            }
                        )
                        
                        Spacer()
                            .frame(height: 20)
                    }
                }
                .frame(minHeight: 96)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(onPurchaseCompleted: nil, onRestoreCompleted: nil)
                .onPurchaseCompleted { customerInfo in
                    subscriptionManager.isSubscribed = customerInfo.entitlements.all["Pro"]?.isActive == true
                    subscriptionManager.customerInfo = customerInfo
                    
                    if let activeSubscription = customerInfo.activeSubscriptions.first {
                        let creditsToAdd = getCreditsForProduct(activeSubscription)
                        subscriptionManager.addCredits(creditsToAdd)
                    }
                }
        }
        .onAppear {
            triggerPageAnimation()
        }
    }
    
    private func triggerPageAnimation() {
        particleAnimation = true
        
        withAnimation(.easeInOut(duration: 0.8)) {
            iconRotation += 360
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            iconScale = 1.2
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                iconScale = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            particleAnimation = false
        }
    }
    
    private func getCreditsForProduct(_ productId: String) -> Int {
        switch productId {
        case "veo3.yearly.com":
            return 500
        case "veo3.monthly.com":
            return 50
        default:
            return 20
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let videoNames: [String]
    let gradient: [Color]
    let accentColor: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool
    
    @State private var currentVideoIndex = 0
    @State private var videoScale: CGFloat = 0.8
    @State private var videoRotation: Double = 0
    @State private var textOpacity: Double = 0
    @State private var videoOpacity: Double = 0
    @State private var pulseAnimation = false
    @State private var videoCarouselTimer: Timer?
    @State private var floatingOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                ForEach(0..<page.videoNames.count, id: \.self) { index in
                    JuicyVideoView(
                        videoName: page.videoNames[index],
                        isActive: currentVideoIndex == index,
                        gradient: page.gradient,
                        accentColor: page.accentColor,
                        index: index,
                        currentIndex: currentVideoIndex
                    )
                    .scaleEffect(currentVideoIndex == index ? 1.0 : 0.6)
                    .opacity(currentVideoIndex == index ? 1.0 : 0.2)
                    .rotationEffect(.degrees(currentVideoIndex == index ? 0 : Double(index * 25)))
                    .offset(
                        x: currentVideoIndex == index ? 0 : CGFloat((index - currentVideoIndex) * 50),
                        y: currentVideoIndex == index ? floatingOffset : CGFloat((index - currentVideoIndex) * 30)
                    )
                    .animation(.easeInOut(duration: 1.0), value: currentVideoIndex)
                    .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: floatingOffset)
                }
                
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [page.accentColor.opacity(0.8), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 6
                    )
                    .frame(width: 340, height: 340)
                    .rotationEffect(.degrees(videoRotation))
                    .scaleEffect(pulseAnimation ? 1.15 : 1.0)
                    .opacity(0.6)
                
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.4), Color.clear],
                            startPoint: .bottomTrailing,
                            endPoint: .topLeading
                        ),
                        lineWidth: 4
                    )
                    .frame(width: 370, height: 370)
                    .rotationEffect(.degrees(-videoRotation * 0.7))
                    .scaleEffect(pulseAnimation ? 0.85 : 1.0)
                    .opacity(0.4)
                
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [page.accentColor.opacity(0.3), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 400, height: 400)
                    .rotationEffect(.degrees(videoRotation * 1.3))
                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                    .opacity(0.3)
            }
            .scaleEffect(isActive ? videoScale : 0.5)
            .opacity(videoOpacity)
            .animation(.spring(response: 0.8, dampingFraction: 0.6), value: isActive)
            
            VStack(spacing: 20) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, page.accentColor, Color.white.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .opacity(textOpacity)
                    .offset(y: textOpacity == 0 ? 40 : 0)
                    .shadow(color: page.accentColor.opacity(0.6), radius: 20, x: 0, y: 8)
                    .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 3)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                
                Text(page.description)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white.opacity(0.9), Color.gray.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .opacity(textOpacity)
                    .offset(y: textOpacity == 0 ? 50 : 0)
                    .lineLimit(4)
                    .minimumScaleFactor(0.9)
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
            }
        }
        .padding()
        .onChange(of: isActive) { active in
            if active {
                triggerAnimations()
                startVideoCarousel()
            } else {
                stopVideoCarousel()
            }
        }
        .onAppear {
            if isActive {
                triggerAnimations()
                startVideoCarousel()
            }
        }
        .onDisappear {
            stopVideoCarousel()
        }
    }
    
    private func triggerAnimations() {
        withAnimation(.spring(response: 1.0, dampingFraction: 0.6)) {
            videoScale = 1.0
            videoOpacity = 1.0
        }
        
        withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
            textOpacity = 1.0
        }
        
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            videoRotation = 360
        }
        
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            pulseAnimation.toggle()
        }
        
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            floatingOffset = 10
        }
    }
    
    private func startVideoCarousel() {
        videoCarouselTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 1.2)) {
                currentVideoIndex = (currentVideoIndex + 1) % page.videoNames.count
            }
        }
    }
    
    private func stopVideoCarousel() {
        videoCarouselTimer?.invalidate()
        videoCarouselTimer = nil
    }
}

struct AnimatedBackground: View {
    let currentPage: Int
    let pages: [OnboardingPage]
    
    @State private var backgroundOffset: CGFloat = 0
    @State private var gradientRotation: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ForEach(0..<pages.count, id: \.self) { index in
                Rectangle()
                    .fill(
                        RadialGradient(
                            colors: [
                                pages[index].accentColor.opacity(currentPage == index ? 0.3 : 0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 50,
                            endRadius: 400
                        )
                    )
                    .rotationEffect(.degrees(gradientRotation))
                    .opacity(currentPage == index ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 1.0), value: currentPage)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                gradientRotation = 360
            }
        }
    }
}

struct AnimatedPageIndicator: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<totalPages, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(currentPage == index ? Color.white : Color.gray.opacity(0.4))
                    .frame(
                        width: currentPage == index ? 24 : 8,
                        height: 8
                    )
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentPage)
                    .shadow(color: currentPage == index ? Color.white.opacity(0.5) : Color.clear, radius: 4)
            }
        }
    }
}

struct JuicyButton: View {
    let title: String
    let gradient: [Color]
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var shimmerOffset: CGFloat = -300
    @State private var pulseAnimation = false
    @State private var glowIntensity: Double = 0.2
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 56)
                    .scaleEffect(pulseAnimation ? 1.02 : 1.0)
                    .shadow(color: Color.white.opacity(glowIntensity), radius: 15, x: 0, y: 8)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.4), Color.clear, Color.white.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, Color.white.opacity(0.3), Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 60)
                    .offset(x: shimmerOffset)
                    .mask(RoundedRectangle(cornerRadius: 20))
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                    .scaleEffect(isPressed ? 0.95 : 1.0)
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onAppear {
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                shimmerOffset = 300
            }
            
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                pulseAnimation.toggle()
            }
            
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowIntensity = 0.4
            }
        }
    }
}

struct ParticleSystem: View {
    let isActive: Bool
    let color: Color
    
    @State private var particles: [Particle] = []
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            ForEach(particles, id: \.id) { particle in
                Circle()
                    .fill(color.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .blur(radius: particle.blur)
            }
        }
        .onChange(of: isActive) { active in
            if active {
                startParticles()
            } else {
                stopParticles()
            }
        }
    }
    
    private func startParticles() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if particles.count < 30 {
                let particle = Particle(
                    position: CGPoint(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    ),
                    size: CGFloat.random(in: 2...8),
                    opacity: Double.random(in: 0.3...0.8),
                    blur: CGFloat.random(in: 0...3)
                )
                particles.append(particle)
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            withAnimation(.easeOut(duration: 1.0)) {
                particles.removeAll()
            }
        }
    }
    
    private func stopParticles() {
        timer?.invalidate()
        timer = nil
        withAnimation(.easeOut(duration: 0.5)) {
            particles.removeAll()
        }
    }
}

struct Particle {
    let id = UUID()
    let position: CGPoint
    let size: CGFloat
    let opacity: Double
    let blur: CGFloat
}

struct JuicyVideoView: View {
    let videoName: String
    let isActive: Bool
    let gradient: [Color]
    let accentColor: Color
    let index: Int
    let currentIndex: Int
    
    @State private var player: AVPlayer?
    @State private var videoScale: CGFloat = 0.9
    @State private var borderPulse = false
    @State private var shadowIntensity: Double = 0.5
    @State private var innerGlow = false
    @State private var rotationEffect: Double = 0
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32)
                .fill(
                    RadialGradient(
                        colors: gradient + [accentColor, accentColor.opacity(0.6)],
                        center: .center,
                        startRadius: 50,
                        endRadius: 200
                    )
                )
                .frame(width: 280, height: 280)
                .scaleEffect(borderPulse ? 1.08 : 1.0)
                .shadow(color: accentColor.opacity(shadowIntensity), radius: 40, x: 0, y: 20)
                .shadow(color: .black.opacity(0.8), radius: 20, x: 0, y: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.6), Color.clear, Color.white.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(
                            LinearGradient(
                                colors: [accentColor.opacity(0.8), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .scaleEffect(innerGlow ? 1.02 : 1.0)
                )
            
            if let player = player {
                VideoPlayer(player: player)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 280, height: 280)
                    .clipped()
                    .background(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    .scaleEffect(videoScale)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.4), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: .black.opacity(0.5), radius: 15, x: 0, y: 8)
            } else {
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.black.opacity(0.4))
                    .frame(width: 280, height: 280)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(2.0)
                    )
            }
            
            if isActive {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [accentColor, accentColor.opacity(0.3), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 8
                    )
                    .frame(width: 320, height: 320)
                    .scaleEffect(borderPulse ? 1.15 : 1.0)
                    .opacity(0.7)
                    .rotationEffect(.degrees(rotationEffect))
                
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.5), Color.clear],
                            startPoint: .bottomTrailing,
                            endPoint: .topLeading
                        ),
                        lineWidth: 4
                    )
                    .frame(width: 340, height: 340)
                    .scaleEffect(borderPulse ? 0.9 : 1.0)
                    .opacity(0.6)
                    .rotationEffect(.degrees(-rotationEffect * 0.7))
            }
        }
        .onAppear {
            setupPlayer()
            if isActive {
                startJuicyAnimations()
            }
        }
        .onChange(of: isActive) { active in
            if active {
                startJuicyAnimations()
                player?.play()
            } else {
                player?.pause()
            }
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
    
    private func setupPlayer() {
        guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
            print("Video not found: \(videoName)")
            return
        }
        
        player = AVPlayer(url: url)
        player?.isMuted = true
        player?.actionAtItemEnd = .none
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            player?.seek(to: .zero)
            player?.play()
        }
        
        if isActive {
            player?.play()
        }
    }
    
    private func startJuicyAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            videoScale = 1.0
        }
        
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            borderPulse.toggle()
        }
        
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            shadowIntensity = 0.9
        }
        
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            innerGlow.toggle()
        }
        
        withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
            rotationEffect = 360
        }
    }
}

struct EnhancedParticleSystem: View {
    let isActive: Bool
    let color: Color
    let particleCount: Int
    
    @State private var particles: [EnhancedParticle] = []
    @State private var timer: Timer?
    
    init(isActive: Bool, color: Color, particleCount: Int = 50) {
        self.isActive = isActive
        self.color = color
        self.particleCount = particleCount
    }
    
    var body: some View {
        ZStack {
            ForEach(particles, id: \.id) { particle in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color.opacity(particle.opacity), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: particle.size / 2
                        )
                    )
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .blur(radius: particle.blur)
                    .scaleEffect(particle.scale)
                    .rotationEffect(.degrees(particle.rotation))
            }
        }
        .onChange(of: isActive) { active in
            if active {
                startEnhancedParticles()
            } else {
                stopEnhancedParticles()
            }
        }
    }
    
    private func startEnhancedParticles() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if particles.count < particleCount {
                let particle = EnhancedParticle(
                    position: CGPoint(
                        x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                        y: CGFloat.random(in: 100...UIScreen.main.bounds.height - 100)
                    ),
                    size: CGFloat.random(in: 4...16),
                    opacity: Double.random(in: 0.2...0.8),
                    blur: CGFloat.random(in: 0...4),
                    scale: CGFloat.random(in: 0.5...1.5),
                    rotation: Double.random(in: 0...360)
                )
                particles.append(particle)
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            withAnimation(.easeOut(duration: 1.5)) {
                particles.removeAll()
            }
        }
    }
    
    private func stopEnhancedParticles() {
        timer?.invalidate()
        timer = nil
        withAnimation(.easeOut(duration: 1.0)) {
            particles.removeAll()
        }
    }
}

struct EnhancedParticle {
    let id = UUID()
    let position: CGPoint
    let size: CGFloat
    let opacity: Double
    let blur: CGFloat
    let scale: CGFloat
    let rotation: Double
}