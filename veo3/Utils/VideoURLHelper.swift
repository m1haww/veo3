import Foundation

struct VideoURLHelper {
    /// Converts a GCS URI to a public HTTPS URL
    /// Example: gs://veo3-videos-bucket/videos/video_1752569666_46866E63.mp4/11879182175466653663/sample_0.mp4
    /// Becomes: https://storage.googleapis.com/veo3-videos-bucket/videos/video_1752569666_46866E63.mp4/11879182175466653663/sample_0.mp4
    static func convertGCSToPublicURL(_ gcsUri: String) -> String {
        // If it's already an HTTPS URL, return as is
        if gcsUri.hasPrefix("https://") || gcsUri.hasPrefix("http://") {
            return gcsUri
        }
        
        // If it's a GCS URI, convert it
        if gcsUri.hasPrefix("gs://") {
            // Remove the gs:// prefix and create public URL
            let path = String(gcsUri.dropFirst(5))
            return "https://storage.googleapis.com/\(path)"
        }
        
        // Return original if not recognized
        return gcsUri
    }
}