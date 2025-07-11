import SwiftUI

struct TextToVideoScreen: View {
    @State private var promptText = ""
    @State private var selectedStyle = "Anime"
    @State private var isGenerating = false
    @State private var generationProgress: Double = 0.0
    @State private var showingSuccess = false
    @State private var animateGradient = false
    @State private var showPromptSuggestions = false
    @State private var selectedAspectRatio = "16:9"
    
    let styles = [
        ("Anime", "🎌", Color.pink),
        ("Cyberpunk", "🤖", Color.cyan),
        ("Fantasy", "🧙‍♂️", Color.purple),
        ("Realistic", "📸", Color.blue),
        ("Horror", "👻", Color.red),
        ("Romance", "💕", Color.pink),
        ("Action", "💥", Color.orange),
        ("Comedy", "😂", Color.yellow)
    ]
    
    let promptSuggestions = [
        "A magical forest with glowing butterflies",
        "Futuristic city at sunset with flying cars",
        "Dragon breathing fire in a castle",
        "Couple dancing under the stars",
        "Epic superhero battle scene",
        "Underwater mermaid kingdom"
    ]
    
    let aspectRatios = ["16:9", "9:16", "1:1", "4:3"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Animated gradient background
                LinearGradient(
                    colors: [
                        Color.black,
                        Color.purple.opacity(0.3),
                        Color.black
                    ],
                    startPoint: animateGradient ? .topLeading : .bottomTrailing,
                    endPoint: animateGradient ? .bottomTrailing : .topLeading
                )
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Cool header
                        VStack(spacing: 8) {
                            HStack {
                                Text("Create")
                                    .font(.system(size: 42, weight: .black))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.white, .purple, .cyan],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                Image(systemName: "sparkles")
                                    .font(.system(size: 30))
                                    .foregroundColor(.yellow)
                                    .rotationEffect(.degrees(animateGradient ? 0 : 360))
                                    .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: animateGradient)
                            }
                            
                            Text("Bring your imagination to life")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 20)
                        
                        // Prompt input section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("What's in your mind?")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: { showPromptSuggestions.toggle() }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "lightbulb.fill")
                                        Text("Ideas")
                                    }
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.yellow)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.yellow.opacity(0.2))
                                    .cornerRadius(15)
                                }
                            }
                            .padding(.horizontal)
                            
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.purple, .cyan, .pink],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                                
                                TextEditor(text: $promptText)
                                    .scrollContentBackground(.hidden)
                                    .foregroundColor(.white)
                                    .padding(16)
                                    .frame(minHeight: 140)
                                
                                if promptText.isEmpty {
                                    Text("Describe your dream video...")
                                        .foregroundColor(.white.opacity(0.5))
                                        .padding(20)
                                        .allowsHitTesting(false)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Prompt suggestions
                            if showPromptSuggestions {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(promptSuggestions, id: \.self) { suggestion in
                                            Button(action: { promptText = suggestion }) {
                                                Text(suggestion)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 10)
                                                    .background(
                                                        LinearGradient(
                                                            colors: [.purple.opacity(0.5), .pink.opacity(0.5)],
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        )
                                                    )
                                                    .cornerRadius(20)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        
                        // Style selection with icons
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Choose your style")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(styles, id: \.0) { style in
                                        StyleCard(
                                            title: style.0,
                                            icon: style.1,
                                            color: style.2,
                                            isSelected: selectedStyle == style.0,
                                            action: { 
                                                withAnimation(.spring()) {
                                                    selectedStyle = style.0
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Video settings
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Aspect Ratio")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            HStack(spacing: 12) {
                                ForEach(aspectRatios, id: \.self) { ratio in
                                    Button(action: { selectedAspectRatio = ratio }) {
                                        Text(ratio)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(selectedAspectRatio == ratio ? .black : .white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(
                                                selectedAspectRatio == ratio ? Color.white : Color.white.opacity(0.2)
                                            )
                                            .cornerRadius(15)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Generate button
                        Button(action: generateVideo) {
                            ZStack {
                                if isGenerating {
                                    // Progress view
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 30)
                                                .fill(Color.white.opacity(0.2))
                                            
                                            RoundedRectangle(cornerRadius: 30)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [.purple, .pink, .cyan],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .frame(width: geometry.size.width * generationProgress)
                                                .animation(.linear, value: generationProgress)
                                        }
                                    }
                                    .frame(height: 60)
                                    
                                    HStack {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                        
                                        Text("Creating magic... \(Int(generationProgress * 100))%")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                } else {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(
                                            LinearGradient(
                                                colors: promptText.isEmpty ? [.gray, .gray.opacity(0.8)] : [.purple, .pink, .cyan],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(height: 60)
                                    
                                    HStack(spacing: 12) {
                                        Image(systemName: "wand.and.stars")
                                            .font(.system(size: 22))
                                        
                                        Text("Generate Video")
                                            .font(.system(size: 18, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                }
                            }
                        }
                        .disabled(promptText.isEmpty || isGenerating)
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("Video Created! 🎉", isPresented: $showingSuccess) {
                Button("View in Gallery") {
                    // Navigate to gallery
                }
                Button("Create Another", role: .cancel) {
                    promptText = ""
                    selectedStyle = "Anime"
                }
            } message: {
                Text("Your \(selectedStyle) style video is ready!")
            }
        }
    }
    
    func generateVideo() {
        isGenerating = true
        generationProgress = 0.0
        
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            generationProgress += 0.02
            
            if generationProgress >= 1.0 {
                timer.invalidate()
                isGenerating = false
                showingSuccess = true
            }
        }
    }
}

struct StyleCard: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            action()
            withAnimation(.spring(response: 0.3)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            isSelected ?
                            LinearGradient(
                                colors: [color, color.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.white.opacity(0.2), Color.white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                    
                    if isSelected {
                        Circle()
                            .stroke(color, lineWidth: 3)
                            .frame(width: 75, height: 75)
                    }
                    
                    Text(icon)
                        .font(.system(size: 32))
                }
                .scaleEffect(isPressed ? 0.9 : 1.0)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    TextToVideoScreen()
}