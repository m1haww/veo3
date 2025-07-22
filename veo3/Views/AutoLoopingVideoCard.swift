import SwiftUI
import AVKit

struct AutoLoopingVideoCard: View {
    let videoName: String
    let title: String
    var isPortrait: Bool = false
    var category: VideoCategory? = nil
    @State private var player: AVPlayer?
    @State private var isLoaded = false
    @ObservedObject private var playerManager = VideoPlayerManager.shared
    
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
