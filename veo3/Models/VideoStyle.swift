import Foundation

struct VideoStyle: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let description: String
    let category: StyleCategory
}

enum StyleCategory: String, CaseIterable {
    case transformation = "Transformation"
    case effects = "Effects"
    case anime = "Anime"
    case superhero = "Superhero"
    case artistic = "Artistic"
}

struct GeneratedVideo: Identifiable {
    let id = UUID()
    let title: String
    let prompt: String
    let styleUsed: String
    let createdAt: Date
    let thumbnailName: String
}