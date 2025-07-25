import SwiftUI

struct StoredVideoThumbnailView: View {
    let video: GeneratedVideo
    
    var body: some View {
        ZStack {
            if let thumbnailData = video.thumbnailData,
               let uiImage = UIImage(data: thumbnailData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
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
