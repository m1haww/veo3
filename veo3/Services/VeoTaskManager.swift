import Foundation
import Combine

class VeoTaskManager: ObservableObject {
    static let shared = VeoTaskManager()
    
    @Published var activeTasks: [VeoTaskInfo] = []
    
    private var taskTimers: [String: Timer] = [:]
    private let queue = DispatchQueue(label: "com.veo3.taskmanager", attributes: .concurrent)
    
    private init() {}
    
    func addTask(_ operationName: String, prompt: String, style: String? = nil) {
        let newTask = VeoTaskInfo(
            operationName: operationName,
            prompt: prompt,
            style: style,
            status: .pending,
            progress: 0.0,
            createdAt: Date()
        )
        
        queue.async(flags: .barrier) {
            DispatchQueue.main.async {
                self.activeTasks.append(newTask)
            }
        }
        
        startMonitoring(operationName: operationName)
    }
    
    func removeTask(_ operationName: String) {
        queue.async(flags: .barrier) {
            self.taskTimers[operationName]?.invalidate()
            self.taskTimers[operationName] = nil
            
            DispatchQueue.main.async {
                self.activeTasks.removeAll { $0.operationName == operationName }
            }
        }
    }
    
    private func updateTask(_ operationName: String, update: @escaping (inout VeoTaskInfo) -> Void) {
        queue.async(flags: .barrier) {
            DispatchQueue.main.async {
                if let index = self.activeTasks.firstIndex(where: { $0.operationName == operationName }) {
                    update(&self.activeTasks[index])
                }
            }
        }
    }
    
    private func startMonitoring(operationName: String) {
        let timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task {
                await self.checkTaskStatus(operationName: operationName)
            }
        }
        
        queue.async(flags: .barrier) {
            self.taskTimers[operationName] = timer
        }
    }
    
    private func checkTaskStatus(operationName: String) async {
        do {
            let status = try await VeoAPIService.shared.getOperationStatus(operationName: operationName)
            
            let progress: Double
            let taskStatus: VeoTaskStatus
            
            if status.done == true {
                progress = 1.0
                if status.response?.videos?.isEmpty == false {
                    taskStatus = .completed
                } else if let filteredCount = status.response?.raiMediaFilteredCount, filteredCount > 0 {
                    taskStatus = .failed
                } else {
                    taskStatus = .failed
                }
            } else {
                // Estimate progress (Veo doesn't provide exact progress)
                let task = activeTasks.first { $0.operationName == operationName }
                let elapsed = Date().timeIntervalSince(task?.createdAt ?? Date())
                progress = min(elapsed / 60.0, 0.9) // Assume ~60 seconds for generation
                taskStatus = .running
            }
            
            updateTask(operationName) { task in
                task.status = taskStatus
                task.progress = progress
                
                if status.done == true {
                    task.completedAt = Date()
                    
                    // Check for API error first
                    if let error = status.error {
                        task.status = .failed
                        task.failureReason = error.message
                    } else if let videos = status.response?.videos,
                       let firstVideo = videos.first {
                        task.outputURL = firstVideo.gcsUri
                        task.outputBase64 = firstVideo.bytesBase64Encoded
                    } else if let reasons = status.response?.raiMediaFilteredReasons {
                        task.status = .failed
                        task.failureReason = "Content filtered: \(reasons.joined(separator: ", "))"
                    } else {
                        task.status = .failed
                        task.failureReason = "Generation completed but no video was returned"
                    }
                }
            }
            
            if status.done == true {
                queue.async(flags: .barrier) {
                    self.taskTimers[operationName]?.invalidate()
                    self.taskTimers[operationName] = nil
                }
            }
            
        } catch {
            print("VeoTaskManager polling error for \(operationName): \(error)")
            
            // Don't stop monitoring on transient network errors
            if let urlError = error as? URLError,
               (urlError.code == .timedOut || urlError.code == .networkConnectionLost || urlError.code == .notConnectedToInternet) {
                print("Transient network error, will retry on next poll")
                return
            }
            
            // Check if it's a done error from the API
            if let data = (error as NSError).userInfo["data"] as? Data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let done = json["done"] as? Bool,
               done == true {
                // This is actually a completion with an error
                updateTask(operationName) { task in
                    task.status = .failed
                    if let errorInfo = json["error"] as? [String: Any],
                       let message = errorInfo["message"] as? String {
                        task.failureReason = message
                    } else {
                        task.failureReason = "Operation failed"
                    }
                    task.completedAt = Date()
                }
            } else {
                // Other errors - mark as failed but don't stop monitoring immediately
                updateTask(operationName) { task in
                    task.status = .failed
                    task.failureReason = error.localizedDescription
                }
            }
            
            // Only stop monitoring after multiple failures or for permanent errors
            queue.async(flags: .barrier) {
                self.taskTimers[operationName]?.invalidate()
                self.taskTimers[operationName] = nil
            }
        }
    }
}

struct VeoTaskInfo: Identifiable {
    let id = UUID()
    let operationName: String
    let prompt: String
    let style: String?
    var status: VeoTaskStatus
    var progress: Double
    let createdAt: Date
    var completedAt: Date?
    var outputURL: String?
    var outputBase64: String?
    var failureReason: String?
}

enum VeoTaskStatus {
    case pending
    case running
    case completed
    case failed
    case cancelled
}

final class VeoTaskProgressViewModel: ObservableObject {
    @Published var status: VeoOperationStatus?
    @Published var progress: Double = 0.0
    
    private var timer: Timer?
    private var operationName: String?
    
    func startMonitoring(operationName: String) {
        self.operationName = operationName
        self.progress = 0.0
        self.status = nil
        
        Task {
            await checkStatus()
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            Task {
                await self.checkStatus()
            }
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        operationName = nil
    }
    
    private func checkStatus() async {
        guard let operationName = operationName else { return }
        
        do {
            let status = try await VeoAPIService.shared.getOperationStatus(operationName: operationName)
            
            await MainActor.run {
                self.status = status
                
                if status.done == true {
                    self.progress = 1.0
                    self.stopMonitoring()
                } else {
                    self.progress = min(self.progress + 0.05, 0.9)
                }
            }
        } catch {
            print("VeoTaskProgressViewModel polling error: \(error)")
            
            if let urlError = error as? URLError,
               (urlError.code == .timedOut || urlError.code == .networkConnectionLost || urlError.code == .notConnectedToInternet) {
                print("Transient network error, will retry on next poll")
                return
            }
            
            await MainActor.run {
                if let data = (error as NSError).userInfo["data"] as? Data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let done = json["done"] as? Bool,
                   done == true {
                    // This is actually a completion with an error
                    self.progress = 0.0
                    self.stopMonitoring()
                } else {
                    // For other errors, just log but keep polling
                    print("Continuing to poll despite error")
                }
            }
        }
    }
}
