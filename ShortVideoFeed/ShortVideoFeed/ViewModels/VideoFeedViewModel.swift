//
//  VideoFeedViewModel.swift
//  ShortVideoFeed
//
//  Created by Tes on 02/02/2026.
//

import Foundation
import Combine

// MARK: - Video Feed View Model
@MainActor
class VideoFeedViewModel: ObservableObject {
    @Published var videos: [Video] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentVideoIndex = 0
    
    private let apiService: PexelsAPIService
    private let likeStorage: LikeStorageService
    private var cancellables = Set<AnyCancellable>()
    
    init(apiService: PexelsAPIService = .shared,
         likeStorage: LikeStorageService = .shared) {
        self.apiService = apiService
        self.likeStorage = likeStorage
    }
    
    // MARK: - Load Videos
    func loadVideos() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedVideos = try await apiService.fetchMultiplePages(
                query: "people",
                totalVideos: 200
            )
            
            videos = fetchedVideos
            isLoading = false
        } catch let error as APIError {
            errorMessage = error.localizedDescription
            isLoading = false
        } catch {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Retry Loading
    func retry() async {
        await loadVideos()
    }
    
    // MARK: - Like Management
    func toggleLike(for video: Video) -> Bool {
        return likeStorage.toggleLike(for: video.id ?? 0)
    }
    
    func getLikeCount(for video: Video) -> Int {
        return likeStorage.getLikeCount(for: video.id ?? 0)
    }
    
    func isLiked(video: Video) -> Bool {
        return likeStorage.isLiked(videoId: video.id ?? 0)
    }
    
    // MARK: - Video Navigation
    func shouldPreloadVideo(at index: Int) -> Bool {
        // Preload videos within 1 index of current
        return abs(index - currentVideoIndex) <= 1
    }
    
    func updateCurrentIndex(_ index: Int) {
        currentVideoIndex = index
    }
}
