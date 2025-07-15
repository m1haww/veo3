import SwiftUI

struct VideoThumbnailCard: View {
    let videoName: String
    let title: String
    var isPortrait: Bool = false
    var category: VideoCategory? = nil
    
    var body: some View {
        AutoLoopingVideoCard(
            videoName: videoName,
            title: title,
            isPortrait: isPortrait,
            category: category
        )
    }
}
