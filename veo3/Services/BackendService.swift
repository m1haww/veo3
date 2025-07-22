import Foundation
import UIKit

final class BackendService {
    static let shared = BackendService()
    
    private let baseURL = "https://veo3-backend-118847640969.europe-west1.run.app"
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 120
        return URLSession(configuration: config)
    }()
    
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
        
        print("[BackendService] Sending video generation request")
        print("[BackendService] Request body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "empty")")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendError.serverError("Invalid response type")
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        if httpResponse.statusCode != 200 {
            var errorMessage = json?["error"] as? String ?? "Unknown error"
            
            if let messageDict = json?["message"] as? [String: Any],
               let errorDict = messageDict["error"] as? [String: Any],
               let detailedMessage = errorDict["message"] as? String {
                errorMessage = detailedMessage
            }
            
            print("[BackendService] Error response - Status: \(httpResponse.statusCode)")
            print("[BackendService] Error message: \(errorMessage)")
            print("[BackendService] Full response: \(String(data: data, encoding: .utf8) ?? "unable to decode")")
            throw BackendError.serverError(errorMessage)
        }
        
        guard let operationName = json?["name"] as? String else {
            print("[BackendService] Error: No operation name in response")
            print("[BackendService] Response data: \(String(data: data, encoding: .utf8) ?? "unable to decode")")
            throw BackendError.invalidResponse
        }
        
        print("[BackendService] Video generation started with operation: \(operationName)")
        return operationName
    }
    
    func getVideoStatus(operationId: String) async throws -> VeoOperationStatus {
        let requestBody = ["operationName": operationId]
        
        let request = createRequest(
            endpoint: "/check-operation",
            method: "POST",
            body: try? JSONSerialization.data(withJSONObject: requestBody)
        )
        
        let (data, response) = try await session.data(for: request)
        
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
