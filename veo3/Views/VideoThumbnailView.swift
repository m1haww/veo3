import SwiftUI
import AVKit

struct VideoThumbnailView: View {
    let videoURL: String
    @State private var thumbnail: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if isLoading {
                // Loading state
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.3), Color.pink.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    )
            } else {
                // Fallback gradient if thumbnail generation fails
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.3), Color.pink.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .onAppear {
            generateThumbnail()
        }
    }
    
    private func generateThumbnail() {
        // Check cache first
        if let cachedImage = ThumbnailCache.shared.getThumbnail(for: videoURL) {
            self.thumbnail = cachedImage
            self.isLoading = false
            return
        }
        
        // Convert GCS URL to public URL if needed
        let publicURL = VideoURLHelper.convertGCSToPublicURL(videoURL)
        
        guard let url = URL(string: publicURL) else {
            isLoading = false
            return
        }
        
        Task {
            await loadThumbnail(from: url)
        }
    }
    
    private func loadThumbnail(from url: URL) async {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize(width: 400, height: 400) // Optimize for performance
        
        let time = CMTime(seconds: 1.0, preferredTimescale: 600)
        
        do {
            let (image, _) = try await imageGenerator.image(at: time)
            let thumbnailImage = UIImage(cgImage: image)
            
            // Cache the thumbnail
            ThumbnailCache.shared.setThumbnail(thumbnailImage, for: videoURL)
            
            await MainActor.run {
                self.thumbnail = thumbnailImage
                self.isLoading = false
            }
        } catch {
            print("Failed to generate thumbnail: \(error)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}

// Simple in-memory cache for thumbnails
class ThumbnailCache {
    static let shared = ThumbnailCache()
    private var cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 50 // Limit cache size
    }
    
    func getThumbnail(for url: String) -> UIImage? {
        return cache.object(forKey: url as NSString)
    }
    
    func setThumbnail(_ image: UIImage, for url: String) {
        cache.setObject(image, forKey: url as NSString)
    }
}