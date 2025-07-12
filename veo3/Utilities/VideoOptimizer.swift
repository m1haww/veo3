import Foundation
import AVFoundation

class VideoOptimizer {
    
    // Video compression settings for app assets
    static let videoSettings: [String: Any] = [
        AVVideoCodecKey: AVVideoCodecType.hevc, // Use HEVC for better compression
        AVVideoWidthKey: 720, // Limit width for smaller size
        AVVideoHeightKey: 1280, // Maintain aspect ratio
        AVVideoCompressionPropertiesKey: [
            AVVideoAverageBitRateKey: 800_000, // 800 kbps - good quality/size balance
            AVVideoProfileLevelKey: AVVideoProfileLevelH264BaselineAutoLevel,
            AVVideoMaxKeyFrameIntervalKey: 30
        ]
    ]
    
    static let audioSettings: [String: Any] = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVNumberOfChannelsKey: 2,
        AVSampleRateKey: 44100,
        AVEncoderBitRateKey: 64_000 // 64 kbps audio
    ]
    
    // Compress video for app bundle
    static func compressVideoForBundle(inputURL: URL, outputURL: URL, completion: @escaping (Bool, Error?) -> Void) {
        let asset = AVURLAsset(url: inputURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality) else {
            completion(false, NSError(domain: "VideoOptimizer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create export session"]))
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
        Task {
            do {
                try await exportSession.export(to: outputURL, as: .mp4)
                completion(true, nil)
            } catch {
                completion(false, error)
            }
        }
    }
}

// Video loading strategies
extension VideoOptimizer {
    
    // Strategy 1: Load video from bundle with caching
    static func loadBundleVideo(named name: String, fileExtension: String = "mp4") -> AVPlayer? {
        guard let path = Bundle.main.path(forResource: name, ofType: fileExtension) else {
            return nil
        }
        
        let url = URL(fileURLWithPath: path)
        let playerItem = AVPlayerItem(url: url)
        
        // Enable buffer optimization
        playerItem.preferredForwardBufferDuration = 2.0
        
        return AVPlayer(playerItem: playerItem)
    }
    
    // Strategy 2: Stream from remote URL (keeps app size small)
    static func streamVideo(from urlString: String) -> AVPlayer? {
        guard let url = URL(string: urlString) else { return nil }
        
        let playerItem = AVPlayerItem(url: url)
        playerItem.preferredForwardBufferDuration = 2.0
        
        return AVPlayer(playerItem: playerItem)
    }
    
    // Strategy 3: Progressive download with caching
    static func loadVideoWithCache(url: URL, cacheKey: String) -> AVPlayer? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent("\(cacheKey).mp4")
        
        // Check if cached
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            return AVPlayer(url: destinationURL)
        }
        
        // Download and cache
        URLSession.shared.downloadTask(with: url) { tempURL, _, error in
            guard let tempURL = tempURL, error == nil else { return }
            
            try? FileManager.default.moveItem(at: tempURL, to: destinationURL)
        }.resume()
        
        // Stream while downloading
        return AVPlayer(url: url)
    }
}