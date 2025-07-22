import Foundation
import AVFoundation

struct NetworkConfiguration {
    /// Creates a safe URLSession for iOS 18.4+ compatibility
    static func safeSession(with config: URLSessionConfiguration? = nil) -> URLSession {
        if #available(iOS 18.4, *) {
            let configuration = config ?? URLSessionConfiguration.ephemeral
            return URLSession(configuration: configuration)
        } else {
            let configuration = config ?? URLSessionConfiguration.default
            return URLSession(configuration: configuration)
        }
    }
    /// Creates a URL session configuration optimized for video streaming
    static func videoStreamingConfiguration() -> URLSessionConfiguration {
        let config: URLSessionConfiguration
        if #available(iOS 18.4, *) {
            config = URLSessionConfiguration.ephemeral
        } else {
            config = URLSessionConfiguration.default
        }
        
        // Increase timeouts for video streaming
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 300
        
        // Allow cellular access
        config.allowsCellularAccess = true
        config.allowsExpensiveNetworkAccess = true
        config.allowsConstrainedNetworkAccess = true
        
        // Configure caching
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,  // 50 MB
            diskCapacity: 200 * 1024 * 1024,   // 200 MB
            diskPath: "video_cache"
        )
        
        return config
    }
    
    /// Creates AVURLAsset options for reliable video loading
    static func videoAssetOptions() -> [String: Any] {
        var options: [String: Any] = [
            AVURLAssetPreferPreciseDurationAndTimingKey: false,
            "AVURLAssetHTTPHeaderFieldsKey": [
                "User-Agent": "VEO3-iOS-App",
                "Accept": "video/*"
            ]
        ]
        
        if #available(iOS 13.0, *) {
            options[AVURLAssetAllowsCellularAccessKey] = true
        }
        
        if #available(iOS 14.0, *) {
            options[AVURLAssetAllowsExpensiveNetworkAccessKey] = true
            options[AVURLAssetAllowsConstrainedNetworkAccessKey] = true
        }
        
        options["AVURLAssetHTTPCookiesKey"] = HTTPCookieStorage.shared.cookies ?? []
        
        return options
    }
}
