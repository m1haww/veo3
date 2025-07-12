import SwiftUI
import AVKit

struct FullWidthVideoPlayer: View {
    let videoName: String
    @State private var player: AVPlayer?
    
    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .disabled(true)
                    .onAppear {
                        player.play()
                    }
            } else {
                // Show thumbnail while loading
                VideoThumbnailView(videoName: videoName)
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
    
    private func setupPlayer() {
        guard let path = Bundle.main.path(forResource: videoName, ofType: "mp4") else { return }
        let url = URL(fileURLWithPath: path)
        
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player?.isMuted = true
        player?.actionAtItemEnd = .none
        
        // Setup looping
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            player?.seek(to: .zero)
            player?.play()
        }
        
        // Start playing
        player?.play()
    }
}