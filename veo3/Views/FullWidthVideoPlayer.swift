import SwiftUI
import AVKit

struct FullWidthVideoPlayer: View {
    let videoName: String
    @State private var player: AVPlayer?
    @State private var isLoaded = false
    @ObservedObject private var playerManager = VideoPlayerManager.shared
    
    var body: some View {
        Group {
            if let player = player, isLoaded {
                VideoPlayer(player: player)
                    .disabled(true)
            } else {
                ImageThumbnailView(videoName: videoName)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                player = playerManager.getPlayer(for: videoName)
                playerManager.playVideo(videoName) { success in
                    DispatchQueue.main.async {
                        self.isLoaded = success
                    }
                }
            }
        }
        .onDisappear {
            playerManager.pauseVideo(videoName)
        }
    }
}
