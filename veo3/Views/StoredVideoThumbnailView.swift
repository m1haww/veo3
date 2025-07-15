import SwiftUI

struct StoredVideoThumbnailView: View {
    let video: GeneratedVideo
    
    var body: some View {
        ZStack {
            if let thumbnailData = video.thumbnailData,
               let uiImage = UIImage(data: thumbnailData) {
                // Show stored thumbnail
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if video.status == .completed, let videoURL = video.videoURL {
                // Fallback to loading thumbnail from video URL
                VideoThumbnailView(videoURL: videoURL)
            } else {
                // Placeholder gradient
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
    }
}