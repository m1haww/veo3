import Foundation

struct GoogleCloudConfig {
    static let projectId = "daring-runway-465515-i2"
    
    static let region = "us-central1"
    
    static let baseURL = "https://\(region)-aiplatform.googleapis.com/v1"
    
    enum VeoModel: String {
        case veo2Generate = "veo-2.0-generate-001"
        case veo3Generate = "veo-3.0-generate-preview"
        case veo3Fast = "veo-3.0-fast-generate-preview"
    }
    
    // Temporary token for testing - update this manually for now
    // Run: gcloud auth print-access-token
    static let accessToken = "YOUR_NEW_ACCESS_TOKEN_HERE"
}

struct VeoError: LocalizedError {
    let error: String
    let message: String?
    
    var errorDescription: String? {
        return message ?? error
    }
}
