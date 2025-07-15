import SwiftUI
import AVKit

struct FullWidthVideoPlayer: View {
    let videoName: String
    @State private var player: AVPlayer?
    @State private var isLoaded = false
    @State private var isInitialized = false
    @State private var notificationObserver: NSObjectProtocol?
    
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
            if !isInitialized {
                // First time setup with slight delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    setupPlayer()
                }
            } else if let player = player {
                // Resume playing if already initialized
                player.play()
            }
        }
        .onDisappear {
            // Just pause, don't cleanup
            player?.pause()
        }
    }
    
    private func setupPlayer() {
        guard player == nil else { return }
        
        // Configure audio session to reduce warnings
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(false)
        
        if let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
            let playerItem = AVPlayerItem(url: url)
            let newPlayer = AVPlayer(playerItem: playerItem)
            
            // Configure player with minimal settings
            newPlayer.isMuted = true
            newPlayer.volume = 0.0
            newPlayer.allowsExternalPlayback = false
            newPlayer.preventsDisplaySleepDuringVideoPlayback = false
            
            // Set up looping
            notificationObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: playerItem,
                queue: .main
            ) { _ in
                newPlayer.seek(to: .zero) { _ in
                    newPlayer.play()
                }
            }
            
            self.player = newPlayer
            self.isInitialized = true
            
            // Check status and play when ready
            if playerItem.status == .readyToPlay {
                self.isLoaded = true
                newPlayer.play()
            } else {
                // Use a timer to check status periodically
                Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
                    if playerItem.status == .readyToPlay {
                        self.isLoaded = true
                        newPlayer.play()
                        timer.invalidate()
                    } else if playerItem.status == .failed {
                        timer.invalidate()
                        // Fallback to showing thumbnail on failure
                        self.player = nil
                        self.isInitialized = false
                    }
                }
            }
        }
    }
    
    private func cleanupPlayer() {
        // Remove notification observer
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
            notificationObserver = nil
        }
        
        // Clean up player
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
        isLoaded = false
    }
}
