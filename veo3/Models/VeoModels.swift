import Foundation

struct VeoVideoGenerationRequest: Codable {
    let instances: [VeoInstance]
    let parameters: VeoParameters
}

struct VeoInstance: Codable {
    let prompt: String?
    let image: VeoImage?
    let lastFrame: VeoImage?
    let video: VeoVideo?
}

struct VeoImage: Codable {
    let bytesBase64Encoded: String?
    let gcsUri: String?
    let mimeType: String
}

struct VeoVideo: Codable {
    let bytesBase64Encoded: String?
    let gcsUri: String?
    let mimeType: String
}

struct VeoParameters: Codable {
    let aspectRatio: String?
    let durationSeconds: Int
    let enhancePrompt: Bool?
    let generateAudio: Bool?
    let negativePrompt: String?
    let personGeneration: String?
    let sampleCount: Int?
    let seed: UInt32?
    let storageUri: String?
}

struct VeoOperationResponse: Codable {
    let name: String
}

struct VeoOperationStatus: Codable {
    let name: String
    let done: Bool?
    let response: VeoGenerationResponse?
    let error: VeoOperationError?
}

struct VeoOperationError: Codable {
    let code: Int
    let message: String
}

struct VeoGenerationResponse: Codable {
    let type: String?
    let raiMediaFilteredCount: Int?
    let raiMediaFilteredReasons: [String]?
    let videos: [VeoGeneratedVideo]?
    
    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case raiMediaFilteredCount
        case raiMediaFilteredReasons
        case videos
    }
}

struct VeoGeneratedVideo: Codable {
    let bytesBase64Encoded: String?
    let gcsUri: String?
    let mimeType: String?
}

enum VeoAspectRatio: String {
    case landscape16x9 = "16:9"
    case portrait9x16 = "9:16"
    
    var displayName: String {
        switch self {
        case .landscape16x9: return "Landscape (16:9)"
        case .portrait9x16: return "Portrait (9:16)"
        }
    }
    
    var aspectRatio: CGFloat {
        switch self {
        case .landscape16x9: return 16/9
        case .portrait9x16: return 9/16
        }
    }
}

enum VeoPersonGeneration: String {
    case allowAdult = "allow_adult"
    case dontAllow = "dont_allow"
}

struct VeoFetchOperationRequest: Codable {
    let operationName: String
}
