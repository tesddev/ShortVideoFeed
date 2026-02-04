//
//  LikeStorageService.swift
//  ShortVideoFeed
//
//  Created by Tes on 02/02/2026.
//

import Foundation

// MARK: - Like Storage Service
class LikeStorageService {
    static let shared = LikeStorageService()
    
    private let defaults = UserDefaults.standard
    private let likesKey = "video_likes"
    private let userLikesKey = "user_liked_videos"
    
    init() {}
    
    // MARK: - Like Management
    
    /// Get like count for a video
    func getLikeCount(for videoId: Int) -> Int {
        let likes = getAllLikes()
        return likes[String(videoId)] ?? Int.random(in: 100...10000) // Mock initial count
    }
    
    /// Toggle like for a video
    func toggleLike(for videoId: Int) -> Bool {
        var userLikes = getUserLikes()
        let videoIdString = String(videoId)
        
        if userLikes.contains(videoIdString) {
            // Unlike
            userLikes.remove(videoIdString)
            decrementLike(for: videoId)
            saveUserLikes(userLikes)
            return false
        } else {
            // Like
            userLikes.insert(videoIdString)
            incrementLike(for: videoId)
            saveUserLikes(userLikes)
            return true
        }
    }
    
    /// Check if user has liked a video
    func isLiked(videoId: Int) -> Bool {
        let userLikes = getUserLikes()
        return userLikes.contains(String(videoId))
    }
    
    /// Get total likes count (for profile)
    func getTotalLikesCount() -> Int {
        let likes = getAllLikes()
        return likes.values.reduce(0, +)
    }
    
    // MARK: - Private Helpers
    
    private func getAllLikes() -> [String: Int] {
        guard let data = defaults.data(forKey: likesKey),
              let likes = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return [:]
        }
        return likes
    }
    
    private func saveAllLikes(_ likes: [String: Int]) {
        if let data = try? JSONEncoder().encode(likes) {
            defaults.set(data, forKey: likesKey)
        }
    }
    
    private func getUserLikes() -> Set<String> {
        guard let array = defaults.array(forKey: userLikesKey) as? [String] else {
            return []
        }
        return Set(array)
    }
    
    private func saveUserLikes(_ likes: Set<String>) {
        defaults.set(Array(likes), forKey: userLikesKey)
    }
    
    private func incrementLike(for videoId: Int) {
        var likes = getAllLikes()
        let videoIdString = String(videoId)
        likes[videoIdString, default: 0] += 1
        saveAllLikes(likes)
    }
    
    private func decrementLike(for videoId: Int) {
        var likes = getAllLikes()
        let videoIdString = String(videoId)
        likes[videoIdString, default: 0] = max(0, likes[videoIdString, default: 0] - 1)
        saveAllLikes(likes)
    }
    
    // MARK: - Reset (for testing)
    func resetAllData() {
        defaults.removeObject(forKey: likesKey)
        defaults.removeObject(forKey: userLikesKey)
    }
}
