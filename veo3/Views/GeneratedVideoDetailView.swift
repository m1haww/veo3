import SwiftUI
import AVKit
import Photos

struct GeneratedVideoDetailView: View {
    @Environment(\.dismiss) var dismiss
    let video: GeneratedVideo
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var showShareSheet = false
    @State private var showDeleteAlert = false
    @State private var isSavingToPhotos = false
    @State private var showSaveAlert = false
    @State private var saveAlertMessage = ""
    @StateObject private var appState = AppStateManager.shared
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 8, height: 8)
                        
                        Text(video.status.displayName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        if video.status == .completed {
                            Button(action: { showShareSheet = true }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                        
                        Button(action: { showDeleteAlert = true }) {
                            Image(systemName: "trash")
                                .font(.system(size: 20))
                                .foregroundColor(.red)
                                .frame(width: 44, height: 44)
                                .background(Color.red.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding()
                .padding(.top)
                
                // Video player or placeholder
                ZStack {
                    if video.status == .completed, let videoURL = video.videoURL {
                        let publicURL = VideoURLHelper.convertGCSToPublicURL(videoURL)
                        if let url = URL(string: publicURL) {
                            VideoPlayer(player: player)
                                .onAppear {
                                    player = AVPlayer(url: url)
                                    player?.play()
                                    isPlaying = true
                                    
                                    // Loop the video
                                    NotificationCenter.default.addObserver(
                                        forName: .AVPlayerItemDidPlayToEndTime,
                                        object: player?.currentItem,
                                        queue: .main
                                    ) { _ in
                                        player?.seek(to: .zero)
                                        player?.play()
                                    }
                                }
                                .onDisappear {
                                    player?.pause()
                                    player = nil
                                }
                        }
                    } else if video.status == .pending {
                        // Pending state
                        VStack(spacing: 20) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                                .scaleEffect(1.5)
                            
                            Text("Video is being generated...")
                                .font(.system(size: 18))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                    } else if video.status == .failed {
                        // Failed state
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.red)
                            
                            Text("Video generation failed")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                            
                            Text("Please try generating again")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                    }
                }
                .aspectRatio(16/9, contentMode: .fit)
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Info section
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Prompt section
                        if let prompt = video.prompt, !prompt.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Prompt")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Text(prompt)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                            }
                        }
                        
                        // Details section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Label("Category", systemImage: "folder")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Spacer()
                                
                                Text(video.category)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                Label("Created", systemImage: "calendar")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Spacer()
                                
                                Text(video.date.formatted())
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        
                        if video.status == .completed {
                            // Action buttons
                            VStack(spacing: 12) {
                                Button(action: regenerateVideo) {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                        Text("Regenerate Video")
                                    }
                                    .font(.system(size: 16, weight: .medium))
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
                                    .cornerRadius(12)
                                }
                                
                                Button(action: saveToPhotos) {
                                    HStack {
                                        if isSavingToPhotos {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(0.8)
                                        } else {
                                            Image(systemName: "square.and.arrow.down")
                                        }
                                        Text(isSavingToPhotos ? "Saving..." : "Save to Photos")
                                    }
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                }
                                .disabled(isSavingToPhotos)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .alert("Delete Video", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                appState.removeGeneratedVideo(video)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this video? This action cannot be undone.")
        }
        .alert("Save to Photos", isPresented: $showSaveAlert) {
            Button("OK") { }
        } message: {
            Text(saveAlertMessage)
        }
        .sheet(isPresented: $showShareSheet) {
            if let videoURL = video.videoURL {
                let publicURL = VideoURLHelper.convertGCSToPublicURL(videoURL)
                if let url = URL(string: publicURL) {
                    ShareSheet(items: [url])
                }
            }
        }
    }
    
    private var statusColor: Color {
        switch video.status {
        case .completed: return .green
        case .pending: return .orange
        case .failed: return .red
        }
    }
    
    private func regenerateVideo() {
        // Navigate to TextToVideoScreen with the same prompt
        dismiss()
        // This will be handled by the parent view
    }
    
    private func saveToPhotos() {
        guard let videoURL = video.videoURL else { return }
        
        let publicURL = VideoURLHelper.convertGCSToPublicURL(videoURL)
        guard let url = URL(string: publicURL) else { return }
        
        isSavingToPhotos = true
        
        // Check photo library permission
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self.downloadAndSaveVideo(from: url)
                case .denied, .restricted:
                    self.isSavingToPhotos = false
                    self.saveAlertMessage = "Photo library access denied. Please enable access in Settings."
                    self.showSaveAlert = true
                case .notDetermined:
                    self.isSavingToPhotos = false
                case .limited:
                    self.downloadAndSaveVideo(from: url)
                @unknown default:
                    self.isSavingToPhotos = false
                }
            }
        }
    }
    
    private func downloadAndSaveVideo(from url: URL) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent("temp_video_\(Date().timeIntervalSince1970).mp4")
        
        // Download the video
        let downloadTask = URLSession.shared.downloadTask(with: url) { location, response, error in
            guard let location = location, error == nil else {
                DispatchQueue.main.async {
                    self.isSavingToPhotos = false
                    self.saveAlertMessage = "Failed to download video. Please check your internet connection."
                    self.showSaveAlert = true
                }
                return
            }
            
            do {
                // Move the downloaded file to a temporary location
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                try FileManager.default.moveItem(at: location, to: destinationURL)
                
                // Save to photo library
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destinationURL)
                }) { success, error in
                    DispatchQueue.main.async {
                        self.isSavingToPhotos = false
                        
                        // Clean up temporary file
                        try? FileManager.default.removeItem(at: destinationURL)
                        
                        if success {
                            self.saveAlertMessage = "Video saved to Photos successfully!"
                        } else {
                            self.saveAlertMessage = "Failed to save video: \(error?.localizedDescription ?? "Unknown error")"
                        }
                        self.showSaveAlert = true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isSavingToPhotos = false
                    self.saveAlertMessage = "Failed to save video: \(error.localizedDescription)"
                    self.showSaveAlert = true
                }
            }
        }
        
        downloadTask.resume()
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
