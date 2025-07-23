import SwiftUI
import AVKit

struct TextToVideoScreen: View {
    @Environment(\.dismiss) var dismiss
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
    @FocusState private var isTextFieldFocused: Bool
    
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
                                        appState.promptText = randomPrompt
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
                                
                                TextEditor(text: $appState.promptText)
                                    .scrollContentBackground(.hidden)
                                    .foregroundColor(.white)
                                    .padding(16)
                                    .frame(minHeight: 120)
                                    .focused($isTextFieldFocused)
                                
                                if appState.promptText.isEmpty {
                                    Text("Describe what you want to see...")
                                        .foregroundColor(.white.opacity(0.3))
                                        .padding(20)
                                        .allowsHitTesting(false)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        HStack(spacing: 24) {
                            HStack(spacing: 8) {
                                Text("Aspect Ratio")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Text(selectedVeoRatio.displayName)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.purple)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Text("Duration")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Text("\(selectedDuration)s")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.purple)
                            }
                        }
                        .padding(.horizontal)
                        
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
                        
                        Button(action: {
                            isTextFieldFocused = false
                            generateVideo()
                        }) {
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
                            .disabled(isGenerating || appState.promptText.isEmpty || !subscriptionManager.hasCredits(generateAudio ? 5 : 4))
                            .opacity((isGenerating || appState.promptText.isEmpty || !subscriptionManager.hasCredits(generateAudio ? 5 : 4)) ? 0.6 : 1)
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
            appState.clearPromptText()
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
        guard !appState.promptText.isEmpty else {
            errorMessage = "Please enter a prompt for video generation"
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
        
        Task { @MainActor in
            withAnimation(.spring()) {
                showingQueuePopup = true
            }
        }
        
        startProgressTimer()
        
        Task {
            do {
                let operationName = try await VeoAPIService.shared.generateVideoFromText(
                    prompt: appState.promptText,
                    model: .veo3Fast,
                    aspectRatio: selectedVeoRatio,
                    durationSeconds: selectedDuration,
                    generateAudio: generateAudio
                )
                print("[TextToVideoScreen] Received operation name: \(operationName)")
                
                generationTaskId = operationName
                
                let category = appState.selectedCategory?.title ?? "Custom"
                
                let pendingVideo = GeneratedVideo(
                    videoFilePath: nil,
                    category: category,
                    status: .pending,
                    prompt: appState.promptText
                )
                AppStateManager.shared.addGeneratedVideo(pendingVideo)
                
                await pollForVideoCompletion(operationName: operationName, category: category, pendingVideoId: pendingVideo.id, creditsRequired: creditsRequired)
            } catch {
                print("[TextToVideoScreen] Error during video generation: \(error)")
                print("[TextToVideoScreen] Error description: \(error.localizedDescription)")
                
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
            let totalDuration: TimeInterval = 120.0
            
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
            appState.promptText = preset.prompt
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
                appState.promptText = preset.prompt
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
                
                if fetchCount % 10 == 0 {
                    print("[TextToVideoScreen] Polling attempt \(fetchCount) - Status: \(status.done ?? false)")
                }
                
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
                    
                    if let error = status.error {
                        self.showingQueuePopup = false
                        self.generationProgress = 0.0
                        
                        if let existingVideo = AppStateManager.shared.generatedVideos.first(where: { $0.id == pendingVideoId }) {
                            let updatedVideo = GeneratedVideo(
                                id: existingVideo.id,
                                date: existingVideo.date,
                                videoFilePath: nil,
                                category: category,
                                status: .failed,
                                prompt: self.appState.promptText,
                                errorMessage: error.message
                            )
                            AppStateManager.shared.updateGeneratedVideo(updatedVideo)
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.errorMessage = error.message
                        }
                    } else if let videos = status.response?.videos,
                              let firstVideo = videos.first,
                              let base64Data = firstVideo.bytesBase64Encoded {
                        if let existingVideo = AppStateManager.shared.generatedVideos.first(where: { $0.id == pendingVideoId }) {
                            let filename = "\(existingVideo.id.uuidString).mp4"
                            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)

                            if let videoData = Data(base64Encoded: base64Data) {
                                try? videoData.write(to: fileURL)
                                
                                let thumbnailData = await ThumbnailGenerator.generateThumbnail(fromLocalFile: fileURL)

                                let completedVideo = GeneratedVideo(
                                    id: existingVideo.id,
                                    date: existingVideo.date,
                                    videoFilePath: fileURL.path,
                                    category: category,
                                    status: .completed,
                                    prompt: self.appState.promptText,
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
                        }
                    } else {
                        let errorMsg = status.response?.raiMediaFilteredReasons?.joined(separator: ", ") ?? "Video generation failed"
                        self.showingQueuePopup = false
                        self.generationProgress = 0.0
                        
                        if let existingVideo = AppStateManager.shared.generatedVideos.first(where: { $0.id == pendingVideoId }) {
                            let updatedVideo = GeneratedVideo(
                                id: existingVideo.id,
                                date: existingVideo.date,
                                videoFilePath: nil,
                                category: category,
                                status: .failed,
                                prompt: self.appState.promptText,
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
                print("[TextToVideoScreen] Polling error: \(error)")
                
                if let urlError = error as? URLError,
                   (urlError.code == .timedOut || urlError.code == .networkConnectionLost || urlError.code == .notConnectedToInternet) {
                    print("[TextToVideoScreen] Network error, retrying...")
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
                            videoFilePath: nil,
                            category: category,
                            status: .failed,
                            prompt: self.appState.promptText,
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
                    videoFilePath: nil,
                    category: category,
                    status: .failed,
                    prompt: self.appState.promptText,
                    errorMessage: "Video generation timed out. Please try again."
                )
                AppStateManager.shared.updateGeneratedVideo(updatedVideo)
            }
            
            self.errorMessage = "Video generation timed out. Please try again."
        }
    }
}
