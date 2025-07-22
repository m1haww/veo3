import Foundation
import AVKit
import UIKit

struct ThumbnailGenerator {
    /// Generates a thumbnail from a local video file URL
    static func generateThumbnail(fromLocalFile fileURL: URL) async -> Data? {
        do {
            return try await generateThumbnailDataFromFile(at: fileURL)
        } catch {
            print("Failed to generate thumbnail from local file: \(error)")
            return nil
        }
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
    
    private static func generateThumbnailDataFromFile(at url: URL) async throws -> Data? {
        let asset = AVURLAsset(url: url)
        
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
