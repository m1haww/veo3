import Foundation
import AVFoundation

final class VideoOptimizer {
    static let videoSettings: [String: Any] = [
        AVVideoCodecKey: AVVideoCodecType.hevc,
        AVVideoWidthKey: 720,
        AVVideoHeightKey: 1280,
        AVVideoCompressionPropertiesKey: [
            AVVideoAverageBitRateKey: 800_000,
            AVVideoProfileLevelKey: AVVideoProfileLevelH264BaselineAutoLevel,
            AVVideoMaxKeyFrameIntervalKey: 30
        ]
    ]
    
    static let audioSettings: [String: Any] = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVNumberOfChannelsKey: 2,
        AVSampleRateKey: 44100,
        AVEncoderBitRateKey: 64_000
    ]
    
    static func compressVideoForBundle(inputURL: URL, outputURL: URL, completion: @escaping (Bool, Error?) -> Void) {
        let asset = AVURLAsset(url: inputURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality) else {
            completion(false, NSError(domain: "VideoOptimizer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create export session"]))
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(true, nil)
            case .failed:
                completion(false, exportSession.error)
            case .cancelled:
                completion(false, NSError(domain: "VideoOptimizer", code: -2, userInfo: [NSLocalizedDescriptionKey: "Export was cancelled"]))
            default:
                completion(false, NSError(domain: "VideoOptimizer", code: -3, userInfo: [NSLocalizedDescriptionKey: "Export failed with unknown status"]))
            }
        }
    }
}

extension VideoOptimizer {
    static func loadBundleVideo(named name: String, fileExtension: String = "mp4") -> AVPlayer? {
        guard let path = Bundle.main.path(forResource: name, ofType: fileExtension) else {
            return nil
        }
        
        let url = URL(fileURLWithPath: path)
        let playerItem = AVPlayerItem(url: url)
        
        playerItem.preferredForwardBufferDuration = 2.0
        
        return AVPlayer(playerItem: playerItem)
    }
    
    static func streamVideo(from urlString: String) -> AVPlayer? {
        guard let url = URL(string: urlString) else { return nil }
        
        let playerItem = AVPlayerItem(url: url)
        playerItem.preferredForwardBufferDuration = 2.0
        
        return AVPlayer(playerItem: playerItem)
    }
    
    static func loadVideoWithCache(url: URL, cacheKey: String) -> AVPlayer? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent("\(cacheKey).mp4")
        
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            return AVPlayer(url: destinationURL)
        }
        
        NetworkConfiguration.safeSession().downloadTask(with: url) { tempURL, _, error in
            guard let tempURL = tempURL, error == nil else { return }
            
            try? FileManager.default.moveItem(at: tempURL, to: destinationURL)
        }.resume()
        
        return AVPlayer(url: url)
    }
}
