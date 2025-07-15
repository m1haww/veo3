import SwiftUI
import AVKit

struct AutoLoopingVideoCard: View {
    let videoName: String
    let title: String
    var isPortrait: Bool = false
    var category: VideoCategory? = nil
    @State private var player: AVPlayer?
    @State private var isLoaded = false
    @State private var isInitialized = false
    @State private var notificationObserver: NSObjectProtocol?
    
    var body: some View {
        Button(action: {
            if let preset = VideoPreset.preset(for: videoName) {
                AppStateManager.shared.selectVideoPreset(preset, category: category)
            }
        }) {
            ZStack(alignment: .bottomLeading) {
                // Content container with fixed size
                Group {
                    if let player = player, isLoaded {
                        VideoPlayer(player: player)
                            .disabled(true)
                    } else {
                        ImageThumbnailView(videoName: videoName)
                    }
                }
                .aspectRatio(isPortrait ? 9/16 : 16/9, contentMode: .fill)
                .frame(width: isPortrait ? 180 : nil, height: isPortrait ? 240 : 140)
                .clipped()
                .cornerRadius(12)
                
                VStack {
                    Spacer()
                    HStack {
                        Text(title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                LinearGradient(
                                    colors: [Color.black.opacity(0.8), Color.black.opacity(0.4)],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                                .cornerRadius(8)
                            )
                        Spacer()
                    }
                    .padding(.leading, 10)
                    .padding(.bottom, 10)
                }
            }
        }
        .frame(width: isPortrait ? 180 : nil, height: isPortrait ? 240 : 140)
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
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
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
            notificationObserver = nil
        }
        
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
        isLoaded = false
    }
}
