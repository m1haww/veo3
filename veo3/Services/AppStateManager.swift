import SwiftUI
import Combine

class AppStateManager: ObservableObject {
    static let shared = AppStateManager()
    
    @Published var selectedVideoPreset: VideoPreset?
    @Published var selectedCategory: VideoCategory?
    @Published var currentTab: Int = 0
    @Published var shouldNavigateToCreate: Bool = false
    @Published var generatedVideos: [GeneratedVideo] = []
    @Published var showPaywall: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let generatedVideosKey = "GeneratedVideosHistory"
    
    private init() {
        loadGeneratedVideos()
    }
    
    func selectVideoPreset(_ preset: VideoPreset, category: VideoCategory? = nil) {
        selectedVideoPreset = preset
        selectedCategory = category
        shouldNavigateToCreate = true
    }
    
    func selectCategory(_ category: VideoCategory) {
        selectedCategory = category
        currentTab = 1
    }
    
    func clearSelectedPreset() {
        selectedVideoPreset = nil
        shouldNavigateToCreate = false
    }
    
    func clearSelectedCategory() {
        selectedCategory = nil
    }
    
    func navigateToTab(_ index: Int) {
        currentTab = index
    }
    
    func presentPaywall() {
        showPaywall = true
    }
    
    func addGeneratedVideo(_ video: GeneratedVideo) {
        generatedVideos.insert(video, at: 0)
        saveGeneratedVideos()
    }
    
    func updateGeneratedVideo(_ video: GeneratedVideo) {
        if let index = generatedVideos.firstIndex(where: { $0.id == video.id }) {
            generatedVideos[index] = video
            saveGeneratedVideos()
        }
    }
    
    func removeGeneratedVideo(_ video: GeneratedVideo) {
        generatedVideos.removeAll { $0.id == video.id }
        saveGeneratedVideos()
    }
    
    func getGeneratedVideos(for category: String? = nil) -> [GeneratedVideo] {
        if let category = category {
            return generatedVideos.filter { $0.category == category }
        }
        return generatedVideos
    }
    
    private func saveGeneratedVideos() {
        if let encoded = try? JSONEncoder().encode(generatedVideos) {
            userDefaults.set(encoded, forKey: generatedVideosKey)
        }
    }
    
    private func loadGeneratedVideos() {
        if let data = userDefaults.data(forKey: generatedVideosKey),
           let decoded = try? JSONDecoder().decode([GeneratedVideo].self, from: data) {
            generatedVideos = decoded
        }
    }
}
