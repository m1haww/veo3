import Foundation
import UIKit

// Backend service for handling API calls through your server
class BackendService {
    static let shared = BackendService()
    
    private let baseURL = "http://localhost:5000"
    // For production, update to: "https://your-domain.com"
    
    private init() {}
    
    func generateVideo(
        image: UIImage? = nil,
        prompt: String?,
        aspectRatio: VeoAspectRatio,
        duration: Int,
        generateAudio: Bool,
        storageUri: String? = nil
    ) async throws -> String {
        var requestBody: [String: Any] = [
            "aspectRatio": aspectRatio.rawValue,
            "durationSeconds": duration,
            "generateAudio": generateAudio,
            "enhancePrompt": true,
            "model": "veo-3.0-fast-generate-preview"
        ]
        
        if let storageUri = storageUri {
            requestBody["storageUri"] = storageUri
        }
        
        // Add prompt if provided
        if let prompt = prompt {
            requestBody["prompt"] = prompt
        }
        
        // Convert image to base64 only if provided
        if let image = image,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            let base64String = imageData.base64EncodedString()
            requestBody["image"] = base64String
            requestBody["imageMimeType"] = "image/jpeg"
        }
        
        let request = createRequest(
            endpoint: "/generate-video",
            method: "POST",
            body: try? JSONSerialization.data(withJSONObject: requestBody)
        )
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendError.serverError("Invalid response type")
        }
        
        // Parse response data
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        // Log the response
        print("=== Backend Generate Video Response ===")
        print("Status Code: \(httpResponse.statusCode)")
        print("Response Body: \(json ?? [:])")
        
        // Check for success
        if httpResponse.statusCode != 200 {
            var errorMessage = json?["error"] as? String ?? "Unknown error"
            
            // Check for nested error message structure
            if let messageDict = json?["message"] as? [String: Any],
               let errorDict = messageDict["error"] as? [String: Any],
               let detailedMessage = errorDict["message"] as? String {
                errorMessage = detailedMessage
            }
            
            print("Error: \(errorMessage)")
            throw BackendError.serverError(errorMessage)
        }
        
        guard let operationName = json?["name"] as? String else {
            print("Error: No operation name in response")
            throw BackendError.invalidResponse
        }
        
        print("Success! Operation Name: \(operationName)")
        print("=====================================")
        
        return operationName
    }
    
    func getVideoStatus(operationId: String) async throws -> VeoOperationStatus {
        let requestBody = ["operationName": operationId]
        
        let request = createRequest(
            endpoint: "/check-operation",
            method: "POST",
            body: try? JSONSerialization.data(withJSONObject: requestBody)
        )
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw BackendError.serverError("Failed to check operation status")
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(VeoOperationStatus.self, from: data)
    }
    
    // MARK: - Helper Methods
    
    private func createRequest(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil
    ) -> URLRequest {
        let url = URL(string: "\(baseURL)\(endpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add your backend authentication if needed
        // request.setValue("Bearer \(backendToken)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
}

// MARK: - Models

struct AuthToken: Codable {
    let token: String
    let expiresIn: Int
}

// MARK: - Errors

enum BackendError: LocalizedError {
    case notImplemented
    case invalidResponse
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "Backend integration not implemented yet"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}
