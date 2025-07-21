import Foundation
import UIKit

final class VeoAPIService {
    static let shared = VeoAPIService()
    
    private init() {}
    
    func generateVideoFromText(
        prompt: String,
        model: GoogleCloudConfig.VeoModel = .veo3Fast,
        aspectRatio: VeoAspectRatio = .landscape16x9,
        durationSeconds: Int = 8,
        enhancePrompt: Bool = true,
        generateAudio: Bool = true,
        sampleCount: Int = 1,
        seed: UInt32? = nil,
        storageUri: String? = nil
    ) async throws -> String {
        // Use the base storage URI - API will create its own folder structure
        let fullStorageUri = storageUri ?? "gs://veo3-videos-bucket/videos"
        
        // Use backend service for text-only generation
        return try await BackendService.shared.generateVideo(
            image: nil,
            prompt: prompt,
            aspectRatio: aspectRatio,
            duration: durationSeconds,
            generateAudio: generateAudio,
            storageUri: fullStorageUri
        )
    }
    
    func generateVideoFromImage(
        image: UIImage,
        prompt: String? = nil,
        model: GoogleCloudConfig.VeoModel = .veo3Fast,
        aspectRatio: VeoAspectRatio = .landscape16x9,
        durationSeconds: Int = 8,
        enhancePrompt: Bool = true,
        generateAudio: Bool = true,
        sampleCount: Int = 1,
        seed: UInt32? = nil,
        storageUri: String? = nil
    ) async throws -> String {
        // Use the base storage URI - API will create its own folder structure
        let fullStorageUri = storageUri ?? "gs://veo3-videos-bucket/videos"
        
        return try await BackendService.shared.generateVideo(
            image: image,
            prompt: prompt,
            aspectRatio: aspectRatio,
            duration: durationSeconds,
            generateAudio: generateAudio,
            storageUri: fullStorageUri
        )
    }
    
    func getOperationStatus(operationName: String) async throws -> VeoOperationStatus {
        return try await BackendService.shared.getVideoStatus(operationId: operationName)
    }
    
    func pollOperationUntilComplete(
        operationName: String,
        pollInterval: TimeInterval = 2.0,
        timeout: TimeInterval = 300.0
    ) async throws -> VeoOperationStatus {
        let startTime = Date()
        
        while Date().timeIntervalSince(startTime) < timeout {
            let status = try await getOperationStatus(operationName: operationName)
            
            if status.done == true {
                if status.response != nil {
                    return status
                } else {
                    throw VeoError(
                        error: "Operation failed",
                        message: "Operation completed but no response was provided"
                    )
                }
            }
            
            try await Task.sleep(nanoseconds: UInt64(pollInterval * 1_000_000_000))
        }
        
        throw VeoError(
            error: "Timeout",
            message: "Operation timed out after \(timeout) seconds"
        )
    }
    
    private func resizeImageIfNeeded(_ image: UIImage) -> UIImage {
        let maxDimension: CGFloat = 1280
        let size = image.size
        
        if size.width <= maxDimension && size.height <= maxDimension {
            return image
        }
        
        let widthRatio = maxDimension / size.width
        let heightRatio = maxDimension / size.height
        let ratio = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
}
