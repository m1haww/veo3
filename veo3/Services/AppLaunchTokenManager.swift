import Foundation

// Manages token refresh on app launch
class AppLaunchTokenManager {
    static let shared = AppLaunchTokenManager()
    
    private var currentToken: String = GoogleCloudConfig.accessToken
    private let tokenKey = "veo3_cached_token"
    private let tokenExpiryKey = "veo3_token_expiry"
    
    private init() {
        // Load cached token if available
        loadCachedToken()
    }
    
    // Call this when app launches
    func refreshTokenIfNeeded() async {
        // Check if current token is still valid
        if isTokenValid() {
            print("✅ Token still valid, no refresh needed")
            return
        }
        
        print("🔄 Token expired, refreshing...")
        
        // For now, we'll use a hybrid approach:
        // 1. Check if there's a fresh token file that was updated by the script
        // 2. If not, prompt user to run the refresh script
        
        if let freshToken = loadTokenFromFile() {
            updateToken(freshToken)
            print("✅ Loaded fresh token from file")
        } else {
            print("⚠️ Please run ./refresh_token.sh to get a fresh token")
            // In a production app, you'd show an alert to the user
        }
    }
    
    func getAccessToken() -> String {
        return currentToken
    }
    
    private func isTokenValid() -> Bool {
        guard let expiryDate = UserDefaults.standard.object(forKey: tokenExpiryKey) as? Date else {
            return false
        }
        
        // Check if token expires in more than 5 minutes
        return expiryDate > Date().addingTimeInterval(300)
    }
    
    private func loadCachedToken() {
        if let cachedToken = UserDefaults.standard.string(forKey: tokenKey),
           isTokenValid() {
            currentToken = cachedToken
        }
    }
    
    private func updateToken(_ token: String) {
        currentToken = token
        UserDefaults.standard.set(token, forKey: tokenKey)
        UserDefaults.standard.set(Date().addingTimeInterval(3300), forKey: tokenExpiryKey) // 55 minutes
        
        // Schedule notification for token expiry
//        TokenExpiryNotifier.shared.scheduleTokenExpiryNotification()
    }
    
    private func loadTokenFromFile() -> String? {
        // Check multiple locations for the token file
        let paths = [
            URL(fileURLWithPath: "/Users/petrugrigor/Documents/veo3/current_token.txt"),
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("current_token.txt")
        ].compactMap { $0 }
        
        for url in paths {
            if let token = try? String(contentsOf: url, encoding: .utf8) {
                let trimmedToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedToken.isEmpty && trimmedToken.starts(with: "ya29.") {
                    return trimmedToken
                }
            }
        }
        
        return nil
    }
}

// MARK: - Easy Integration
extension AppLaunchTokenManager {
    // Simple async wrapper for VeoAPIService
    func getAccessTokenAsync() async throws -> String {
        // First, try to refresh if needed
        await refreshTokenIfNeeded()
        
        let token = getAccessToken()
        
        // Validate token format
        guard token.starts(with: "ya29.") || token.count > 100 else {
            throw TokenError.invalidToken
        }
        
        return token
    }
}

enum TokenError: LocalizedError {
    case invalidToken
    case refreshNeeded
    
    var errorDescription: String? {
        switch self {
        case .invalidToken:
            return "Invalid token format. Please run ./refresh_token.sh"
        case .refreshNeeded:
            return "Token needs refresh. Please run ./refresh_token.sh"
        }
    }
}
