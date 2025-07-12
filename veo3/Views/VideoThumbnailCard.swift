import SwiftUI
import AVKit

struct VideoThumbnailCard: View {
    let videoName: String
    let title: String
    @State private var showingPlayer = false
    @State private var player: AVPlayer?
    
    var body: some View {
        Button(action: {
            showingPlayer = true
        }) {
            ZStack(alignment: .bottom) {
                // Autoplay video thumbnail
                if let player = player {
                    VideoPlayer(player: player)
                        .disabled(true)
                        .frame(height: 140)
                        .clipped()
                        .cornerRadius(12)
                        .onAppear {
                            player.isMuted = true
                            player.play()
                        }
                } else {
                    VideoThumbnailView(videoName: videoName)
                        .frame(height: 140)
                        .clipped()
                        .cornerRadius(12)
                }
                
                // Play button overlay
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.8))
                    .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [Color.black.opacity(0.7), Color.black.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
            }
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .onAppear {
            setupAutoplayVideo()
        }
        .onDisappear {
            player?.pause()
        }
        .fullScreenCover(isPresented: $showingPlayer) {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VideoPlayerView(videoName: videoName)
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Button(action: {
                            showingPlayer = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding()
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    private func setupAutoplayVideo() {
        if let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
            player = AVPlayer(url: url)
            player?.isMuted = true
            player?.play()
            
            // Setup looping
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
}