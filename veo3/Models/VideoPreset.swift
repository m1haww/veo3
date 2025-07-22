import Foundation

struct VideoPreset: Identifiable, Equatable {
    let id = UUID()
    let videoAssetName: String
    let title: String
    let prompt: String
    let style: String
    let category: PresetCategory
    let isPortrait: Bool
    
    init(videoAssetName: String, title: String, prompt: String, style: String, category: PresetCategory, isPortrait: Bool = false) {
        self.videoAssetName = videoAssetName
        self.title = title
        self.prompt = prompt
        self.style = style
        self.category = category
        self.isPortrait = isPortrait
    }
    
    static func == (lhs: VideoPreset, rhs: VideoPreset) -> Bool {
        return lhs.id == rhs.id
    }
}

enum PresetCategory: String, CaseIterable {
    case bigfoot = "Bigfoot"
    case interviews = "Interviews"
    case reports = "Reports"
    case sirena = "Sirena"
    case portraits = "Portraits"
    case fantasy = "Fantasy"
    case custom = "Custom"
}

extension VideoPreset {
    static let presets: [VideoPreset] = [
        VideoPreset(
            videoAssetName: "bigfoot1",
            title: "Bigfoot Vlog Day",
            prompt: "Daily vlog featuring unexpected Bigfoot encounter, personal footage style",
            style: "Vlog",
            category: .bigfoot
        ),
        VideoPreset(
            videoAssetName: "bigfoot2",
            title: "Jungle Encounter",
            prompt: "Deep jungle expedition discovers massive cryptid creature in dense foliage",
            style: "Documentary",
            category: .bigfoot
        ),
        VideoPreset(
            videoAssetName: "bigfoot3",
            title: "Yoga With Sasquatch",
            prompt: "Bizarre yoga studio encounter with Bigfoot joining the morning session",
            style: "Lifestyle",
            category: .bigfoot
        ),
        VideoPreset(
            videoAssetName: "interview1",
            title: "Street Talk",
            prompt: "Street interviews on busy city boulevard, asking locals about trending topics",
            style: "News",
            category: .interviews
        ),
        VideoPreset(
            videoAssetName: "interview2",
            title: "Beach Chat",
            prompt: "Beachside interviews with tourists and locals on sunny beach",
            style: "Documentary",
            category: .interviews
        ),
        VideoPreset(
            videoAssetName: "interview3",
            title: "City Opinions",
            prompt: "Busy city square street interviews capturing diverse urban perspectives",
            style: "Lifestyle",
            category: .interviews
        ),
        VideoPreset(
            videoAssetName: "report1",
            title: "Breaking News Update",
            prompt: "Reporter on scene covering breaking news story with live updates from the field",
            style: "News",
            category: .reports
        ),
        VideoPreset(
            videoAssetName: "report2",
            title: "Field Report Live",
            prompt: "Journalist reporting from downtown location with developing story details",
            style: "Journalism",
            category: .reports
        ),
        VideoPreset(
            videoAssetName: "report3",
            title: "Granny's Sports Car Joyride",
            prompt: "Hilarious news coverage of grandmother taking green sports car for unexpected joyride",
            style: "Broadcast",
            category: .reports
        ),
        VideoPreset(
            videoAssetName: "sirena1",
            title: "Ocean Dream",
            prompt: "Ethereal underwater swimming with mermaid-like grace in crystal blue waters",
            style: "Fantasy",
            category: .sirena,
            isPortrait: true
        ),
        VideoPreset(
            videoAssetName: "sirena2",
            title: "Aqua Dance",
            prompt: "Graceful underwater dance performance with flowing movements",
            style: "Artistic",
            category: .sirena,
            isPortrait: true
        ),
        VideoPreset(
            videoAssetName: "sirena3",
            title: "Crystal Waters",
            prompt: "Serene underwater beauty with sunlight filtering through clear water",
            style: "Performance",
            category: .sirena,
            isPortrait: true
        ),
        VideoPreset(
            videoAssetName: "sirena4",
            title: "Mermaid Lagoon",
            prompt: "Mystical underwater scene in tropical lagoon with mermaid-inspired movements",
            style: "Fantasy",
            category: .sirena,
            isPortrait: true
        ),
        VideoPreset(
            videoAssetName: "girl1",
            title: "Golden Hour",
            prompt: "Beautiful girl portrait during golden hour with warm sunset lighting",
            style: "Portrait",
            category: .portraits,
            isPortrait: true
        ),
        VideoPreset(
            videoAssetName: "girl2",
            title: "City Lights",
            prompt: "Beautiful girl in urban setting with neon lights and city backdrop at night",
            style: "Cinematic",
            category: .portraits,
            isPortrait: true
        ),
        VideoPreset(
            videoAssetName: "girl3",
            title: "Nature Walk",
            prompt: "Beautiful girl enjoying nature walk in outdoor forest setting",
            style: "Lifestyle",
            category: .portraits,
            isPortrait: true
        ),
        VideoPreset(
            videoAssetName: "girl4",
            title: "Coffee Time",
            prompt: "Beautiful girl in cozy cafe with warm atmosphere and coffee",
            style: "Lifestyle",
            category: .portraits,
            isPortrait: true
        ),
        VideoPreset(
            videoAssetName: "girl5",
            title: "Beach Vibes",
            prompt: "Beautiful girl at beach with ocean waves and summer vibes",
            style: "Travel",
            category: .portraits,
            isPortrait: true
        ),
        VideoPreset(
            videoAssetName: "girl6",
            title: "Night Out",
            prompt: "Beautiful girl in elegant evening attire with sophisticated styling",
            style: "Fashion",
            category: .portraits,
            isPortrait: true
        ),
        VideoPreset(
            videoAssetName: "fantasy1",
            title: "Dragon Realm",
            prompt: "Epic fantasy scene with dragons flying over ancient kingdoms",
            style: "Fantasy",
            category: .fantasy
        ),
        VideoPreset(
            videoAssetName: "fantasy2",
            title: "Fairy Garden",
            prompt: "Magical fairy garden with glowing flowers and mystical creatures",
            style: "Fantasy",
            category: .fantasy
        ),
        VideoPreset(
            videoAssetName: "fantasy3",
            title: "Magic Castle",
            prompt: "Enchanted castle with floating towers and magical aurora",
            style: "Fantasy",
            category: .fantasy
        ),
        VideoPreset(
            videoAssetName: "fantasy4",
            title: "Enchanted Forest",
            prompt: "Mystical forest with glowing trees and magical atmosphere",
            style: "Fantasy",
            category: .fantasy
        )
    ]
    
    static func preset(for videoName: String) -> VideoPreset? {
        return presets.first { $0.videoAssetName == videoName }
    }
}
