//
//  ProfileViewModel.swift
//  ShortVideoFeed
//
//  Created by Tes on 02/02/2026.
//

import Foundation

// MARK: - Profile View Model
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var userVideos: [Video] = []
    @Published var totalLikes: Int = 0
    @Published var selectedVideo: Video?
    @Published var showVideoPlayer = false
    
    private let likeStorage: LikeStorageService
    
    // Mock user data
    let user = User(id: 1, name: "John Doe", url: "https://pexels.com")
    
    init(likeStorage: LikeStorageService = .shared) {
        self.likeStorage = likeStorage
    }
    
    // MARK: - Load Profile Data
    func loadProfileData(from allVideos: [Video]) {
        // In a real app, we'd filter by user ID
        // For demo, we'll use random videos to simulate user's content
        let videoCount = min(20, allVideos.count)
        userVideos = Array(allVideos.shuffled().prefix(videoCount))
        
        // Calculate total likes
        totalLikes = likeStorage.getTotalLikesCount()
    }
    
    // MARK: - Video Selection
    func selectVideo(_ video: Video) {
        // Reset first to ensure clean state
        selectedVideo = nil
        showVideoPlayer = false
        
        // Use a small delay to ensure the view is dismissed and reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.selectedVideo = video
            self?.showVideoPlayer = true
        }
    }
    
    func closeVideoPlayer() {
        selectedVideo = nil
        showVideoPlayer = false
    }
    
    // MARK: - Stats
    var videoCount: Int {
        userVideos.count
    }
    
    var followersCount: Int {
        Int.random(in: 1000...100000) // Mock data
    }
    
    var followingCount: Int {
        Int.random(in: 100...1000) // Mock data
    }
}
