import Foundation
import AVKit
import UIKit

struct ThumbnailGenerator {
    /// Generates a thumbnail from a video URL and returns it as base64 encoded data
    static func generateThumbnail(from videoURL: String) async -> Data? {
        // Convert GCS URL to public URL if needed
        let publicURL = VideoURLHelper.convertGCSToPublicURL(videoURL)
        
        guard let url = URL(string: publicURL) else {
            return nil
        }
        
        // Try up to 3 times with exponential backoff
        for attempt in 0..<3 {
            do {
                let thumbnailData = try await generateThumbnailData(from: url)
                return thumbnailData
            } catch {
                print("Failed to generate thumbnail (attempt \(attempt + 1)): \(error)")
                
                // Check if it's a network error that might be recoverable
                if let urlError = error as? URLError,
                   (urlError.code == .timedOut || 
                    urlError.code == .networkConnectionLost || 
                    urlError.code == .notConnectedToInternet ||
                    urlError.code == .cannotParseResponse) {
                    // Wait before retrying (exponential backoff)
                    if attempt < 2 {
                        try? await Task.sleep(nanoseconds: UInt64((attempt + 1) * 1_000_000_000))
                        continue
                    }
                }
                
                // Non-recoverable error or final attempt
                return nil
            }
        }
        
        return nil
    }
    
    private static func generateThumbnailData(from url: URL) async throws -> Data? {
        // Use optimized network configuration
        let asset = AVURLAsset(url: url, options: NetworkConfiguration.videoAssetOptions())
        
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize(width: 400, height: 400) // Optimize size
        imageGenerator.requestedTimeToleranceBefore = CMTime(seconds: 2, preferredTimescale: 600)
        imageGenerator.requestedTimeToleranceAfter = CMTime(seconds: 2, preferredTimescale: 600)
        
        let time = CMTime(seconds: 1.0, preferredTimescale: 600)
        
        let (image, _) = try await imageGenerator.image(at: time)
        let uiImage = UIImage(cgImage: image)
        
        // Compress to JPEG with reasonable quality to reduce storage size
        return uiImage.jpegData(compressionQuality: 0.7)
    }
}
