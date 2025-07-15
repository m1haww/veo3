import SwiftUI

struct VerticalVideoThumbnailCard: View {
    let videoName: String
    let title: String
    var category: VideoCategory? = nil
    
    var body: some View {
        Button(action: {
            if let preset = VideoPreset.preset(for: videoName) {
                AppStateManager.shared.selectVideoPreset(preset, category: category)
            }
        }) {
            ZStack(alignment: .bottomLeading) {
                ImageThumbnailView(videoName: videoName)
                    .aspectRatio(9/16, contentMode: .fill)
                    .frame(width: 180, height: 240)
                    .clipped()
                    .cornerRadius(12)
                
                VStack {
                    Spacer()
                    HStack {
                        Text(title)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                LinearGradient(
                                    colors: [Color.black.opacity(0.7), Color.black.opacity(0.3)],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                                .cornerRadius(8)
                            )
                        Spacer()
                    }
                    .padding(.leading, 8)
                    .padding(.bottom, 8)
                }
            }
        }
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}
