import SwiftUI

struct TextToVideoScreen: View {
    @State private var promptText = ""
    @State private var selectedStyle = "Anime Style"
    @State private var isGenerating = false
    @State private var generationProgress: Double = 0.0
    @State private var showingSuccess = false
    
    let availableStyles = [
        "Anime Style", "Cyberpunk", "Superhero", "Fantasy",
        "Realistic", "Cartoon", "Watercolor", "Oil Painting"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Create Your AI Video")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Describe what you want to see")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Enter your prompt")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        TextEditor(text: $promptText)
                            .frame(minHeight: 120)
                            .padding(12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.horizontal)
                            .overlay(
                                Group {
                                    if promptText.isEmpty {
                                        Text("E.g., A warrior fighting a dragon in a mystical forest...")
                                            .foregroundColor(.gray)
                                            .padding(.horizontal, 28)
                                            .padding(.top, 20)
                                            .allowsHitTesting(false)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select a style")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(availableStyles, id: \.self) { style in
                                    StylePill(
                                        title: style,
                                        isSelected: selectedStyle == style,
                                        action: { selectedStyle = style }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    if isGenerating {
                        VStack(spacing: 16) {
                            ProgressView(value: generationProgress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                                .scaleEffect(y: 2)
                            
                            Text("Generating your video...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    Button(action: generateVideo) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Generate Video")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.purple, Color.purple.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .disabled(promptText.isEmpty || isGenerating)
                        .opacity(promptText.isEmpty || isGenerating ? 0.6 : 1.0)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 50)
                }
                .padding(.top)
            }
            .navigationBarHidden(true)
            .alert("Video Generated!", isPresented: $showingSuccess) {
                Button("View in Gallery") {
                    // Navigate to gallery
                }
                Button("Create Another", role: .cancel) {
                    promptText = ""
                }
            }
        }
    }
    
    func generateVideo() {
        isGenerating = true
        generationProgress = 0.0
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            generationProgress += 0.05
            
            if generationProgress >= 1.0 {
                timer.invalidate()
                isGenerating = false
                showingSuccess = true
            }
        }
    }
}

struct StylePill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(isSelected ? Color.purple : Color.gray.opacity(0.2))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

#Preview {
    TextToVideoScreen()
}