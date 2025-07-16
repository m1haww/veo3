import SwiftUI
import AVKit

struct TextToVideoScreen: View {
    @Environment(\.dismiss) var dismiss
    @State private var promptText = ""
    @State private var isGenerating = false
    @State private var generationProgress: Double = 0.0
    @State private var showingSuccess = false
    @State private var selectedVeoRatio: VeoAspectRatio = .landscape16x9
    @State private var selectedDuration: Int = 8
    @State private var generateAudio: Bool = true
    @State private var generationTaskId: String?
    @State private var errorMessage: String?
    @State private var currentOperationStatus: VeoOperationStatus?
    @State private var pollingTimer: Timer?
    @State private var showingQueuePopup = false
    @StateObject private var appState = AppStateManager.shared
    @State private var completedVideo: GeneratedVideo?
    @State private var showingVideoDetail = false
    @State private var progressTimer: Timer?
    @State private var progressStartTime: Date?
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    
    let promptSuggestions = [
        "A magical forest with glowing butterflies",
        "Futuristic city at sunset with flying cars",
        "Dragon breathing fire in a castle",
        "Couple dancing under the stars",
        "Epic superhero battle scene",
        "Underwater mermaid kingdom"
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Create Video")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 40, height: 40)
                }
                .padding()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        if let category = appState.selectedCategory {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Video Examples")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(category.videos, id: \.fileName) { video in
                                            Button(action: {
                                                loadVideoThumbnail(video.fileName)
                                            }) {
                                                ZStack {
                                                    if let preset = VideoPreset.preset(for: video.fileName),
                                                       preset.videoAssetName == appState.selectedVideoPreset?.videoAssetName {
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(Color.purple, lineWidth: 3)
                                                            .frame(width: 80, height: 80)
                                                    }
                                                    
                                                    ImageThumbnailView(videoName: video.fileName)
                                                        .frame(width: 80, height: 80)
                                                        .clipped()
                                                        .cornerRadius(12)
                                                }
                                                .padding(.vertical, 3)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Describe your video")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: {
                                    if let randomPrompt = promptSuggestions.randomElement() {
                                        promptText = randomPrompt
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "dice.fill")
                                        Text("Ideas")
                                    }
                                    .font(.system(size: 14))
                                    .foregroundColor(.purple)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.purple.opacity(0.2))
                                    .cornerRadius(20)
                                }
                            }
                            
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                                
                                TextEditor(text: $promptText)
                                    .scrollContentBackground(.hidden)
                                    .foregroundColor(.white)
                                    .padding(16)
                                    .frame(minHeight: 120)
                                
                                if promptText.isEmpty {
                                    Text("Describe what you want to see...")
                                        .foregroundColor(.white.opacity(0.3))
                                        .padding(20)
                                        .allowsHitTesting(false)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Aspect Ratio")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            HStack(spacing: 12) {
                                ForEach([VeoAspectRatio.landscape16x9], id: \.self) { ratio in
                                    Button(action: { selectedVeoRatio = ratio }) {
                                        VStack(spacing: 8) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .strokeBorder(
                                                    selectedVeoRatio == ratio ? Color.purple : Color.white.opacity(0.2),
                                                    lineWidth: 2
                                                )
                                                .aspectRatio(ratio.aspectRatio, contentMode: .fit)
                                                .frame(height: 60)
                                            
                                            Text(ratio.displayName)
                                                .font(.system(size: 12))
                                                .foregroundColor(selectedVeoRatio == ratio ? .purple : .white.opacity(0.6))
                                        }
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Duration")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            HStack(spacing: 12) {
                                ForEach([8], id: \.self) { duration in
                                    Button(action: { selectedDuration = duration }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "timer")
                                                .font(.system(size: 16))
                                            Text("\(duration)s")
                                                .font(.system(size: 16, weight: .medium))
                                        }
                                        .foregroundColor(selectedDuration == duration ? .white : .white.opacity(0.6))
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedDuration == duration ? 
                                                    LinearGradient(
                                                        colors: [.purple.opacity(0.6), .pink.opacity(0.6)],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    ) : 
                                                    LinearGradient(
                                                        colors: [Color.white.opacity(0.05), Color.white.opacity(0.05)],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    selectedDuration == duration ? Color.purple : Color.white.opacity(0.2),
                                                    lineWidth: selectedDuration == duration ? 2 : 1
                                                )
                                        )
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Generate Audio")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Toggle("", isOn: $generateAudio)
                                    .toggleStyle(SwitchToggleStyle(tint: .purple))
                                    .labelsHidden()
                            }
                            .padding(.horizontal)
                            
                            Text("Add AI-generated sound effects and music to your video")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal)
                        }
                        
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Credits needed: \(generateAudio ? 5 : 4)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            if !subscriptionManager.hasCredits(generateAudio ? 5 : 4) {
                                Button(action: {
                                    dismiss()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        AppStateManager.shared.presentPaywall()
                                    }
                                }) {
                                    Text("Get More")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.purple)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.purple.opacity(0.2))
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        
                        Button(action: generateVideo) {
                            HStack {
                                if isGenerating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "sparkles")
                                    Text("Generate Video")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .disabled(isGenerating || promptText.isEmpty || !subscriptionManager.hasCredits(generateAudio ? 5 : 4))
                            .opacity((isGenerating || promptText.isEmpty || !subscriptionManager.hasCredits(generateAudio ? 5 : 4)) ? 0.6 : 1)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
            }
            
            if showingQueuePopup {
                VideoGenerationQueueView(
                    isShowing: $showingQueuePopup,
                    progress: $generationProgress,
                    taskStatus: getTaskStatus(),
                    onCancel: {
                        cancelGeneration()
                    }
                )
                .transition(.opacity)
                .zIndex(1000)
            }
        }
        .onAppear {
            loadSelectedPreset()
        }
        .onDisappear {
            appState.clearSelectedPreset()
            appState.clearSelectedCategory()
        }
        .fullScreenCover(isPresented: $showingVideoDetail) {
            if let video = completedVideo {
                GeneratedVideoDetailView(video: video)
                    .onDisappear {
                        dismiss()
                    }
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    func generateVideo() {
        guard !promptText.isEmpty else {
            errorMessage = "Please enter a prompt for video generation"
            isGenerating = false
            return
        }
        
        let creditsRequired = generateAudio ? 5 : 4
        if !subscriptionManager.hasCredits(creditsRequired) {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                AppStateManager.shared.presentPaywall()
            }
            return
        }
        
        isGenerating = true
        generationProgress = 0.0
        errorMessage = nil
        withAnimation(.spring()) {
            showingQueuePopup = true
        }
        
        startProgressTimer()
        
        Task {
            do {
                let operationName = try await VeoAPIService.shared.generateVideoFromText(
                    prompt: promptText,
                    model: .veo3Fast,
                    aspectRatio: selectedVeoRatio,
                    durationSeconds: selectedDuration,
                    generateAudio: generateAudio
                )
                
                
                generationTaskId = operationName
                
                let category = appState.selectedCategory?.title ?? "Custom"
                
                let pendingVideo = GeneratedVideo(
                    videoURL: nil,
                    category: category,
                    status: .pending,
                    prompt: promptText
                )
                AppStateManager.shared.addGeneratedVideo(pendingVideo)
                
                await pollForVideoCompletion(operationName: operationName, category: category, pendingVideoId: pendingVideo.id, creditsRequired: creditsRequired)
            } catch {
                await MainActor.run {
                    self.isGenerating = false
                    self.showingQueuePopup = false
                    self.generationProgress = 0.0
                    self.stopProgressTimer()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    func cancelGeneration() {
        isGenerating = false
        showingQueuePopup = false
        generationProgress = 0.0
        
        stopProgressTimer()
        
        pollingTimer?.invalidate()
        pollingTimer = nil
    }
    
    func startProgressTimer() {
        progressStartTime = Date()
        progressTimer?.invalidate()
        
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            guard let startTime = self.progressStartTime else { return }
            
            let elapsed = Date().timeIntervalSince(startTime)
            let totalDuration: TimeInterval = 180.0 // 3 minutes
            
            let calculatedProgress = min(elapsed / totalDuration, 0.95)
            
            withAnimation(.linear(duration: 0.5)) {
                self.generationProgress = calculatedProgress
            }
            
            if calculatedProgress >= 0.95 {
                self.progressTimer?.invalidate()
                self.progressTimer = nil
            }
        }
    }
    
    func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
        progressStartTime = nil
    }
    
    func loadSelectedPreset() {
        if let preset = AppStateManager.shared.selectedVideoPreset {
            promptText = preset.prompt
            selectedVeoRatio = .landscape16x9
            
            if let url = Bundle.main.url(forResource: preset.videoAssetName, withExtension: "mp4") {
                let asset = AVAsset(url: url)
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                imageGenerator.appliesPreferredTrackTransform = true
                
            }
        }
    }
    
    func getTaskStatus() -> TaskStatus? {
        guard let status = currentOperationStatus else {
            return .pending
        }
        
        if status.done == true {
            if status.error != nil {
                return .failed
            } else if status.response?.videos?.isEmpty == false {
                return .succeeded
            } else {
                return .failed
            }
        } else {
            return .running
        }
    }
    
    func loadVideoThumbnail(_ videoName: String) {
        if let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
            let asset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            if let preset = VideoPreset.preset(for: videoName) {
                appState.selectedVideoPreset = preset
                promptText = preset.prompt
                selectedVeoRatio = .landscape16x9
            }
        }
    }
    
    func pollForVideoCompletion(operationName: String, category: String, pendingVideoId: UUID, creditsRequired: Int) async {
        var fetchCount = 0
        let maxFetches = 150
        
        while fetchCount < maxFetches {
            do {
                let status = try await VeoAPIService.shared.getOperationStatus(operationName: operationName)
                
                await MainActor.run {
                    self.currentOperationStatus = status
                }
                
                if status.done == true {
                    await MainActor.run {
                        self.isGenerating = false
                        self.stopProgressTimer()
                        
                        withAnimation(.easeOut(duration: 0.3)) {
                            self.generationProgress = 1.0
                        }
                    }
                    
                    try await Task.sleep(nanoseconds: 500_000_000)
                    
                    if let error = status.error {
                        self.showingQueuePopup = false
                        self.generationProgress = 0.0
                        
                        if let existingVideo = AppStateManager.shared.generatedVideos.first(where: { $0.id == pendingVideoId }) {
                            let updatedVideo = GeneratedVideo(
                                id: existingVideo.id,
                                date: existingVideo.date,
                                videoURL: nil,
                                category: category,
                                status: .failed,
                                prompt: self.promptText,
                                errorMessage: error.message
                            )
                            AppStateManager.shared.updateGeneratedVideo(updatedVideo)
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.errorMessage = error.message
                        }
                    } else if let videos = status.response?.videos,
                       let firstVideo = videos.first,
                       let videoUrl = firstVideo.gcsUri ?? firstVideo.bytesBase64Encoded {
                        
                        if let existingVideo = AppStateManager.shared.generatedVideos.first(where: { $0.id == pendingVideoId }) {
                            let thumbnailData = await ThumbnailGenerator.generateThumbnail(from: videoUrl)
                            
                            let completedVideo = GeneratedVideo(
                                id: existingVideo.id,
                                date: existingVideo.date,
                                videoURL: videoUrl,
                                category: category,
                                status: .completed,
                                prompt: self.promptText,
                                thumbnailData: thumbnailData
                            )
                            
                            await MainActor.run {
                                AppStateManager.shared.updateGeneratedVideo(completedVideo)
                                self.completedVideo = completedVideo
                                
                                _ = self.subscriptionManager.useCredits(creditsRequired)
                                
                                self.showingQueuePopup = false
                                self.showingVideoDetail = true
                            }
                        }
                    } else {
                        let errorMsg = status.response?.raiMediaFilteredReasons?.joined(separator: ", ") ?? "Video generation failed"
                        self.showingQueuePopup = false
                        self.generationProgress = 0.0
                        
                        if let existingVideo = AppStateManager.shared.generatedVideos.first(where: { $0.id == pendingVideoId }) {
                            let updatedVideo = GeneratedVideo(
                                id: existingVideo.id,
                                date: existingVideo.date,
                                videoURL: nil,
                                category: category,
                                status: .failed,
                                prompt: self.promptText,
                                errorMessage: errorMsg
                            )
                            AppStateManager.shared.updateGeneratedVideo(updatedVideo)
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.errorMessage = errorMsg
                        }
                    }

                    
                    return
                }
                
                try await Task.sleep(nanoseconds: 2_000_000_000)
                fetchCount += 1
            } catch {
                if let urlError = error as? URLError,
                   (urlError.code == .timedOut || urlError.code == .networkConnectionLost || urlError.code == .notConnectedToInternet) {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    fetchCount += 1
                    continue
                }
                
                await MainActor.run {
                    self.isGenerating = false
                    self.showingQueuePopup = false
                    self.generationProgress = 0.0
                    self.stopProgressTimer()
                    
                    if let existingVideo = AppStateManager.shared.generatedVideos.first(where: { $0.id == pendingVideoId }) {
                        let updatedVideo = GeneratedVideo(
                            id: existingVideo.id,
                            date: existingVideo.date,
                            videoURL: nil,
                            category: category,
                            status: .failed,
                            prompt: self.promptText,
                            errorMessage: error.localizedDescription
                        )
                        AppStateManager.shared.updateGeneratedVideo(updatedVideo)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.errorMessage = error.localizedDescription
                    }
                }
                return
            }
        }
        
        await MainActor.run {
            self.isGenerating = false
            self.showingQueuePopup = false
            self.generationProgress = 0.0
            self.stopProgressTimer()
            
            if let existingVideo = AppStateManager.shared.generatedVideos.first(where: { $0.id == pendingVideoId }) {
                let updatedVideo = GeneratedVideo(
                    id: existingVideo.id,
                    date: existingVideo.date,
                    videoURL: nil,
                    category: category,
                    status: .failed,
                    prompt: self.promptText,
                    errorMessage: "Video generation timed out. Please try again."
                )
                AppStateManager.shared.updateGeneratedVideo(updatedVideo)
            }
            
            self.errorMessage = "Video generation timed out. Please try again."
        }
    }
}
