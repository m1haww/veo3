import SwiftUI

struct GalleryScreen: View {
    @State private var selectedFilter = "All"
    @State private var searchText = ""
    
    let filters = ["All", "Recent", "Favorites", "Anime", "Superhero", "Effects"]
    
    let mockVideos = [
        GeneratedVideo(
            title: "Epic Warrior Battle",
            prompt: "A warrior fighting a dragon in a mystical forest",
            styleUsed: "Fantasy",
            createdAt: Date(),
            thumbnailName: "🐉"
        ),
        GeneratedVideo(
            title: "Cyberpunk City",
            prompt: "Neon-lit futuristic city at night",
            styleUsed: "Cyberpunk",
            createdAt: Date().addingTimeInterval(-3600),
            thumbnailName: "🌃"
        ),
        GeneratedVideo(
            title: "Anime Transformation",
            prompt: "Transform into anime character with special powers",
            styleUsed: "Anime Style",
            createdAt: Date().addingTimeInterval(-7200),
            thumbnailName: "⚡"
        ),
        GeneratedVideo(
            title: "Superhero Mode",
            prompt: "Become Batman with dark knight effects",
            styleUsed: "Superhero",
            createdAt: Date().addingTimeInterval(-10800),
            thumbnailName: "🦇"
        ),
        GeneratedVideo(
            title: "Magical Effects",
            prompt: "Add fire and explosion effects to video",
            styleUsed: "Effects",
            createdAt: Date().addingTimeInterval(-14400),
            thumbnailName: "🔥"
        ),
        GeneratedVideo(
            title: "Watercolor Art",
            prompt: "Convert video to beautiful watercolor painting",
            styleUsed: "Watercolor",
            createdAt: Date().addingTimeInterval(-18000),
            thumbnailName: "🎨"
        )
    ]
    
    var filteredVideos: [GeneratedVideo] {
        let filtered = selectedFilter == "All" ? mockVideos : mockVideos.filter { 
            $0.styleUsed.localizedCaseInsensitiveContains(selectedFilter) 
        }
        
        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { 
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.prompt.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(filters, id: \.self) { filter in
                            FilterChip(
                                title: filter,
                                isSelected: selectedFilter == filter,
                                action: { selectedFilter = filter }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color.gray.opacity(0.1))
                
                if filteredVideos.isEmpty {
                    EmptyGalleryView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredVideos) { video in
                                VideoCard(video: video)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Videos")
            .searchable(text: $searchText, prompt: "Search videos...")
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.purple : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct VideoCard: View {
    let video: GeneratedVideo
    @State private var isFavorite = false
    
    var body: some View {
        HStack(spacing: 16) {
            Text(video.thumbnailName)
                .font(.system(size: 40))
                .frame(width: 80, height: 80)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(video.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(video.prompt)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Label(video.styleUsed, systemImage: "paintbrush.fill")
                        .font(.caption)
                        .foregroundColor(.purple)
                    
                    Spacer()
                    
                    Text(timeAgo(from: video.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Button(action: { isFavorite.toggle() }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .red : .gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let hours = Int(interval / 3600)
        
        if hours < 1 {
            return "Just now"
        } else if hours < 24 {
            return "\(hours)h ago"
        } else {
            return "\(hours / 24)d ago"
        }
    }
}

struct EmptyGalleryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "video.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Videos Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create your first AI video to see it here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    GalleryScreen()
}