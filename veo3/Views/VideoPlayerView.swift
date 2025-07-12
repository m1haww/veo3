import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoName: String
    @State private var player: AVPlayer?
    
    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                if let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
                    player = AVPlayer(url: url)
                    player?.play()
                    
                    NotificationCenter.default.addObserver(
                        forName: .AVPlayerItemDidPlayToEndTime,
                        object: player?.currentItem,
                        queue: .main
                    ) { _ in
                        player?.seek(to: .zero)
                        player?.play()
                    }
                }
            }
            .onDisappear {
                player?.pause()
                player = nil
            }
    }
}

