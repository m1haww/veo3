import SwiftUI
import AVKit

struct OptimizedVideoPlayer: View {
    let videoName: String
    let showControls: Bool
    @State private var player: AVPlayer?
    @State private var isLoading = true
    
    init(videoName: String, showControls: Bool = false) {
        self.videoName = videoName
        self.showControls = showControls
    }
    
    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player) {
                    if !showControls {
                        EmptyView()
                    }
                }
                .onAppear {
                    player.play()
                    player.actionAtItemEnd = .none
                    
                    // Loop video
                    NotificationCenter.default.addObserver(
                        forName: .AVPlayerItemDidPlayToEndTime,
                        object: player.currentItem,
                        queue: .main
                    ) { _ in
                        player.seek(to: .zero)
                        player.play()
                    }
                }
                .onDisappear {
                    player.pause()
                }
            } else if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .onAppear {
            loadVideo()
        }
    }
    
    private func loadVideo() {
        // Try to load from bundle first
        if let bundlePlayer = VideoOptimizer.loadBundleVideo(named: videoName) {
            self.player = bundlePlayer
            self.isLoading = false
        } else {
            // Fallback to streaming
            let videoURL = "https://your-cdn.com/videos/\(videoName).mp4"
            if let streamPlayer = VideoOptimizer.streamVideo(from: videoURL) {
                self.player = streamPlayer
                self.isLoading = false
            }
        }
    }
}

// Thumbnail generator for video previews
struct VideoThumbnailView: View {
    let videoName: String
    @State private var thumbnail: UIImage?
    
    var body: some View {
        Group {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            }
        }
        .onAppear {
            generateThumbnail()
        }
    }
    
    private func generateThumbnail() {
        guard let path = Bundle.main.path(forResource: videoName, ofType: "mp4") else { return }
        let url = URL(fileURLWithPath: path)
        
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 1, preferredTimescale: 60)
        
        DispatchQueue.global().async {
            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                let uiImage = UIImage(cgImage: cgImage)
                
                DispatchQueue.main.async {
                    self.thumbnail = uiImage
                }
            } catch {
                print("Failed to generate thumbnail: \(error)")
            }
        }
    }
}