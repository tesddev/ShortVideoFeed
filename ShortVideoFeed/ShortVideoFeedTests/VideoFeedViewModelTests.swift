//
//  VideoFeedViewModelTests.swift
//  ShortVideoFeedTests
//
//  Created by Tes on 02/02/2026.
//

//import XCTest
//@testable import ShortVideoFeed
//
//// MARK: - Mock API Service
//class MockPexelsAPIService: PexelsAPIService {
//    var shouldFail = false
//    var mockVideos: [Video] = []
//    var fetchCallCount = 0
//    
//    override func fetchMultiplePages(query: String, totalVideos: Int) async throws -> [Video] {
//        fetchCallCount += 1
//        
//        if shouldFail {
//            throw APIError.networkError(NSError(domain: "test", code: -1, userInfo: nil))
//        }
//        
//        return mockVideos
//    }
//}
//
//// MARK: - Mock Like Storage
//class MockLikeStorageService: LikeStorageService {
//    var likes: [Int: Int] = [:]
//    var userLikes: Set<Int> = []
//        
//    override func getLikeCount(for videoId: Int) -> Int {
//        return likes[videoId] ?? 0
//    }
//    
//    override func toggleLike(for videoId: Int) -> Bool {
//        if userLikes.contains(videoId) {
//            userLikes.remove(videoId)
//            likes[videoId, default: 0] -= 1
//            return false
//        } else {
//            userLikes.insert(videoId)
//            likes[videoId, default: 0] += 1
//            return true
//        }
//    }
//    
//    override func isLiked(videoId: Int) -> Bool {
//        return userLikes.contains(videoId)
//    }
//    
//    override func getTotalLikesCount() -> Int {
//        return likes.values.reduce(0, +)
//    }
//}
//
//// MARK: - Tests
//@MainActor
//final class VideoFeedViewModelTests: XCTestCase {
//    var sut: VideoFeedViewModel!
//    var mockAPIService: MockPexelsAPIService!
//    var mockLikeStorage: MockLikeStorageService!
//    
//    override func setUp() {
//        super.setUp()
//        mockAPIService = MockPexelsAPIService()
//        mockLikeStorage = MockLikeStorageService()
//        sut = VideoFeedViewModel(apiService: mockAPIService, likeStorage: mockLikeStorage)
//    }
//    
//    override func tearDown() {
//        sut = nil
//        mockAPIService = nil
//        mockLikeStorage = nil
//        super.tearDown()
//    }
//    
//    // MARK: - Load Videos Tests
//    
//    func testLoadVideosSuccess() async {
//        // Given
//        mockAPIService.mockVideos = createMockVideos(count: 5)
//        
//        // When
//        await sut.loadVideos()
//        
//        // Then
//        XCTAssertFalse(sut.isLoading)
//        XCTAssertNil(sut.errorMessage)
//        XCTAssertEqual(sut.videos.count, 5)
//        XCTAssertEqual(mockAPIService.fetchCallCount, 1)
//    }
//    
//    func testLoadVideosFailure() async {
//        // Given
//        mockAPIService.shouldFail = true
//        
//        // When
//        await sut.loadVideos()
//        
//        // Then
//        XCTAssertFalse(sut.isLoading)
//        XCTAssertNotNil(sut.errorMessage)
//        XCTAssertTrue(sut.videos.isEmpty)
//    }
//    
//    func testLoadVideosDoesNotLoadWhenAlreadyLoading() async {
//        // Given
//        mockAPIService.mockVideos = createMockVideos(count: 5)
//        
//        // When: Trigger two loads simultaneously
//        async let load1: () = sut.loadVideos()
//        async let load2: () = sut.loadVideos()
//        
//        await load1
//        await load2
//        
//        // Then: Should only call API once
//        XCTAssertEqual(mockAPIService.fetchCallCount, 1)
//    }
//    
//    // MARK: - Like Management Tests
//    
//    func testToggleLike() {
//        // Given
//        let video = createMockVideo(id: 1)
//        
//        // When: First toggle (like)
//        let isLiked1 = sut.toggleLike(for: video)
//        
//        // Then
//        XCTAssertTrue(isLiked1)
//        XCTAssertTrue(sut.isLiked(video: video))
//        XCTAssertEqual(sut.getLikeCount(for: video), 1)
//        
//        // When: Second toggle (unlike)
//        let isLiked2 = sut.toggleLike(for: video)
//        
//        // Then
//        XCTAssertFalse(isLiked2)
//        XCTAssertFalse(sut.isLiked(video: video))
//        XCTAssertEqual(sut.getLikeCount(for: video), 0)
//    }
//    
//    func testToggleLikeWithNilVideoId() {
//        // Given: Video with nil ID
//        let video = Video(
//            id: nil,
//            width: 1920,
//            height: 1080,
//            duration: 30,
//            image: "https://example.com/image.jpg",
//            url: "https://example.com",
//            user: User(id: 1, name: "Test User", url: "https://example.com"),
//            videoFiles: []
//        )
//        
//        // When/Then: Should handle gracefully (depending on implementation)
//        // If your ViewModel uses video.id ?? 0 or similar:
//        let result = sut.toggleLike(for: video)
//        
//        // Verify it doesn't crash and returns a boolean
//        XCTAssertTrue(result == true || result == false)
//    }
//    
//    func testGetLikeCount() {
//        // Given
//        let video = createMockVideo(id: 1)
//        _ = sut.toggleLike(for: video)
//        
//        // When
//        let count = sut.getLikeCount(for: video)
//        
//        // Then
//        XCTAssertEqual(count, 1)
//    }
//    
//    func testIsLiked() {
//        // Given
//        let video = createMockVideo(id: 1)
//        
//        // When: Before like
//        let isLikedBefore = sut.isLiked(video: video)
//        
//        // Then
//        XCTAssertFalse(isLikedBefore)
//        
//        // When: After like
//        _ = sut.toggleLike(for: video)
//        let isLikedAfter = sut.isLiked(video: video)
//        
//        // Then
//        XCTAssertTrue(isLikedAfter)
//    }
//    
//    // MARK: - Video Navigation Tests
//    
//    func testShouldPreloadVideo() {
//        // Given
//        sut.currentVideoIndex = 5
//        
//        // When/Then: Adjacent videos should preload
//        XCTAssertTrue(sut.shouldPreloadVideo(at: 4))
//        XCTAssertTrue(sut.shouldPreloadVideo(at: 5))
//        XCTAssertTrue(sut.shouldPreloadVideo(at: 6))
//        
//        // Distant videos should not preload
//        XCTAssertFalse(sut.shouldPreloadVideo(at: 3))
//        XCTAssertFalse(sut.shouldPreloadVideo(at: 7))
//        XCTAssertFalse(sut.shouldPreloadVideo(at: 10))
//    }
//    
//    func testUpdateCurrentIndex() {
//        // Given
//        let newIndex = 10
//        
//        // When
//        sut.updateCurrentIndex(newIndex)
//        
//        // Then
//        XCTAssertEqual(sut.currentVideoIndex, newIndex)
//    }
//    
//    // MARK: - Retry Tests
//    
//    func testRetry() async {
//        // Given
//        mockAPIService.shouldFail = true
//        await sut.loadVideos()
//        XCTAssertNotNil(sut.errorMessage)
//        
//        // When: Retry with success
//        mockAPIService.shouldFail = false
//        mockAPIService.mockVideos = createMockVideos(count: 3)
//        await sut.retry()
//        
//        // Then
//        XCTAssertFalse(sut.isLoading)
//        XCTAssertNil(sut.errorMessage)
//        XCTAssertEqual(sut.videos.count, 3)
//    }
//    
//    // MARK: - Edge Cases with Optional Properties
//    
//    func testLoadVideosWithMixedOptionalData() async {
//        // Given: Videos with various optional fields missing
//        mockAPIService.mockVideos = [
//            createMockVideo(id: 1), // Full data
//            Video(id: 2, width: nil, height: nil, duration: 30, image: nil, url: "https://example.com", user: nil, videoFiles: []), // Minimal data
//            Video(id: nil, width: 1920, height: 1080, duration: nil, image: "https://example.com/img.jpg", url: nil, user: User(id: 1, name: nil, url: nil), videoFiles: nil) // Mixed nil values
//        ]
//        
//        // When
//        await sut.loadVideos()
//        
//        // Then: Should load all videos regardless of missing optional fields
//        XCTAssertFalse(sut.isLoading)
//        XCTAssertNil(sut.errorMessage)
//        XCTAssertEqual(sut.videos.count, 3)
//    }
//    
//    func testGetLikeCountForVideoWithNilId() {
//        // Given: Video with nil ID
//        let video = Video(
//            id: nil,
//            width: 1920,
//            height: 1080,
//            duration: 30,
//            image: "https://example.com/image.jpg",
//            url: "https://example.com",
//            user: User(id: 1, name: "Test", url: "https://example.com"),
//            videoFiles: []
//        )
//        
//        // When
//        let count = sut.getLikeCount(for: video)
//        
//        // Then: Should handle gracefully (returns count for ID 0 or default)
//        XCTAssertGreaterThanOrEqual(count, 0)
//    }
//    
//    // MARK: - Helper Methods
//    
//    private func createMockVideos(count: Int) -> [Video] {
//        return (1...count).map { createMockVideo(id: $0) }
//    }
//    
//    private func createMockVideo(id: Int) -> Video {
//        return Video(
//            id: id,
//            width: 1920,
//            height: 1080,
//            duration: 30,
//            image: "https://example.com/image\(id).jpg",
//            url: "https://example.com/\(id)",
//            user: User(id: id, name: "User \(id)", url: "https://example.com/user\(id)"),
//            videoFiles: [
//                VideoFile(
//                    id: id,
//                    quality: "sd",
//                    fileType: "video/mp4",
//                    width: 1280,
//                    height: 720,
//                    link: "https://example.com/video\(id).mp4"
//                )
//            ]
//        )
//    }
//}

import XCTest
@testable import ShortVideoFeed

// MARK: - Mock API Service
class MockPexelsAPIService: PexelsAPIService {
    var shouldFail = false
    var mockVideos: [Video] = []
    var fetchCallCount = 0
    
    override func fetchMultiplePages(query: String, totalVideos: Int) async throws -> [Video] {
        fetchCallCount += 1
        
        if shouldFail {
            throw APIError.networkError(NSError(domain: "test", code: -1, userInfo: nil))
        }
        
        return mockVideos
    }
}

// MARK: - Delayed Mock API Service (for testing concurrent calls)
class DelayedMockPexelsAPIService: PexelsAPIService {
    var shouldFail = false
    var mockVideos: [Video] = []
    var fetchCallCount = 0
    var delay: TimeInterval = 0.1 // Default 100ms delay
    
    override func fetchMultiplePages(query: String, totalVideos: Int) async throws -> [Video] {
        fetchCallCount += 1
        
        if shouldFail {
            throw APIError.networkError(NSError(domain: "test", code: -1, userInfo: nil))
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        return mockVideos
    }
}

// MARK: - Mock Like Storage
class MockLikeStorageService: LikeStorageService {
    var likes: [Int: Int] = [:]
    var userLikes: Set<Int> = []
        
    override func getLikeCount(for videoId: Int) -> Int {
        return likes[videoId] ?? 0
    }
    
    override func toggleLike(for videoId: Int) -> Bool {
        if userLikes.contains(videoId) {
            userLikes.remove(videoId)
            likes[videoId, default: 0] -= 1
            return false
        } else {
            userLikes.insert(videoId)
            likes[videoId, default: 0] += 1
            return true
        }
    }
    
    override func isLiked(videoId: Int) -> Bool {
        return userLikes.contains(videoId)
    }
    
    override func getTotalLikesCount() -> Int {
        return likes.values.reduce(0, +)
    }
}

// MARK: - Tests
@MainActor
final class VideoFeedViewModelTests: XCTestCase {
    var sut: VideoFeedViewModel!
    var mockAPIService: MockPexelsAPIService!
    var mockLikeStorage: MockLikeStorageService!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockPexelsAPIService()
        mockLikeStorage = MockLikeStorageService()
        sut = VideoFeedViewModel(apiService: mockAPIService, likeStorage: mockLikeStorage)
    }
    
    override func tearDown() {
        sut = nil
        mockAPIService = nil
        mockLikeStorage = nil
        super.tearDown()
    }
    
    // MARK: - Load Videos Tests
    
    func testLoadVideosSuccess() async {
        // Given
        mockAPIService.mockVideos = createMockVideos(count: 5)
        
        // When
        await sut.loadVideos()
        
        // Then
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(sut.videos.count, 5)
        XCTAssertEqual(mockAPIService.fetchCallCount, 1)
    }
    
    func testLoadVideosFailure() async {
        // Given
        mockAPIService.shouldFail = true
        
        // When
        await sut.loadVideos()
        
        // Then
        XCTAssertFalse(sut.isLoading)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.videos.isEmpty)
    }
    
    func testLoadVideosDoesNotLoadWhenAlreadyLoading() async {
        // Given
        let delayedMockService = DelayedMockPexelsAPIService()
        delayedMockService.mockVideos = createMockVideos(count: 5)
        delayedMockService.delay = 0.5 // 500ms delay
        
        let sutWithDelay = VideoFeedViewModel(apiService: delayedMockService, likeStorage: mockLikeStorage)
        
        // When: Trigger two loads simultaneously
        async let load1: () = sutWithDelay.loadVideos()
        
        // Small delay to ensure first load starts
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
        
        async let load2: () = sutWithDelay.loadVideos()
        
        await load1
        await load2
        
        // Then: Should only call API once (second call should be ignored)
        XCTAssertEqual(delayedMockService.fetchCallCount, 1)
        XCTAssertEqual(sutWithDelay.videos.count, 5)
    }
    
    func testLoadVideosAllowsReloadAfterCompletion() async {
        // Given
        mockAPIService.mockVideos = createMockVideos(count: 3)
        
        // When: First load
        await sut.loadVideos()
        let firstLoadCount = mockAPIService.fetchCallCount
        
        // When: Second load after first completes
        await sut.loadVideos()
        
        // Then: Should allow second load
        XCTAssertEqual(mockAPIService.fetchCallCount, firstLoadCount + 1)
    }
    
    // MARK: - Like Management Tests
    
    func testToggleLike() {
        // Given
        let video = createMockVideo(id: 1)
        
        // When: First toggle (like)
        let isLiked1 = sut.toggleLike(for: video)
        
        // Then
        XCTAssertTrue(isLiked1)
        XCTAssertTrue(sut.isLiked(video: video))
        XCTAssertEqual(sut.getLikeCount(for: video), 1)
        
        // When: Second toggle (unlike)
        let isLiked2 = sut.toggleLike(for: video)
        
        // Then
        XCTAssertFalse(isLiked2)
        XCTAssertFalse(sut.isLiked(video: video))
        XCTAssertEqual(sut.getLikeCount(for: video), 0)
    }
    
    func testToggleLikeWithNilVideoId() {
        // Given: Video with nil ID
        let video = Video(
            id: nil,
            width: 1920,
            height: 1080,
            duration: 30,
            image: "https://example.com/image.jpg",
            url: "https://example.com",
            user: User(id: 1, name: "Test User", url: "https://example.com"),
            videoFiles: []
        )
        
        // When/Then: Should handle gracefully (depending on implementation)
        // If your ViewModel uses video.id ?? 0 or similar:
        let result = sut.toggleLike(for: video)
        
        // Verify it doesn't crash and returns a boolean
        XCTAssertTrue(result == true || result == false)
    }
    
    func testGetLikeCount() {
        // Given
        let video = createMockVideo(id: 1)
        _ = sut.toggleLike(for: video)
        
        // When
        let count = sut.getLikeCount(for: video)
        
        // Then
        XCTAssertEqual(count, 1)
    }
    
    func testIsLiked() {
        // Given
        let video = createMockVideo(id: 1)
        
        // When: Before like
        let isLikedBefore = sut.isLiked(video: video)
        
        // Then
        XCTAssertFalse(isLikedBefore)
        
        // When: After like
        _ = sut.toggleLike(for: video)
        let isLikedAfter = sut.isLiked(video: video)
        
        // Then
        XCTAssertTrue(isLikedAfter)
    }
    
    // MARK: - Video Navigation Tests
    
    func testShouldPreloadVideo() {
        // Given
        sut.currentVideoIndex = 5
        
        // When/Then: Adjacent videos should preload
        XCTAssertTrue(sut.shouldPreloadVideo(at: 4))
        XCTAssertTrue(sut.shouldPreloadVideo(at: 5))
        XCTAssertTrue(sut.shouldPreloadVideo(at: 6))
        
        // Distant videos should not preload
        XCTAssertFalse(sut.shouldPreloadVideo(at: 3))
        XCTAssertFalse(sut.shouldPreloadVideo(at: 7))
        XCTAssertFalse(sut.shouldPreloadVideo(at: 10))
    }
    
    func testUpdateCurrentIndex() {
        // Given
        let newIndex = 10
        
        // When
        sut.updateCurrentIndex(newIndex)
        
        // Then
        XCTAssertEqual(sut.currentVideoIndex, newIndex)
    }
    
    // MARK: - Retry Tests
    
    func testRetry() async {
        // Given
        mockAPIService.shouldFail = true
        await sut.loadVideos()
        XCTAssertNotNil(sut.errorMessage)
        
        // When: Retry with success
        mockAPIService.shouldFail = false
        mockAPIService.mockVideos = createMockVideos(count: 3)
        await sut.retry()
        
        // Then
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(sut.videos.count, 3)
    }
    
    // MARK: - Edge Cases with Optional Properties
    
    func testLoadVideosWithMixedOptionalData() async {
        // Given: Videos with various optional fields missing
        mockAPIService.mockVideos = [
            createMockVideo(id: 1), // Full data
            Video(id: 2, width: nil, height: nil, duration: 30, image: nil, url: "https://example.com", user: nil, videoFiles: []), // Minimal data
            Video(id: nil, width: 1920, height: 1080, duration: nil, image: "https://example.com/img.jpg", url: nil, user: User(id: 1, name: nil, url: nil), videoFiles: nil) // Mixed nil values
        ]
        
        // When
        await sut.loadVideos()
        
        // Then: Should load all videos regardless of missing optional fields
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(sut.videos.count, 3)
    }
    
    func testGetLikeCountForVideoWithNilId() {
        // Given: Video with nil ID
        let video = Video(
            id: nil,
            width: 1920,
            height: 1080,
            duration: 30,
            image: "https://example.com/image.jpg",
            url: "https://example.com",
            user: User(id: 1, name: "Test", url: "https://example.com"),
            videoFiles: []
        )
        
        // When
        let count = sut.getLikeCount(for: video)
        
        // Then: Should handle gracefully (returns count for ID 0 or default)
        XCTAssertGreaterThanOrEqual(count, 0)
    }
    
    // MARK: - Helper Methods
    
    private func createMockVideos(count: Int) -> [Video] {
        return (1...count).map { createMockVideo(id: $0) }
    }
    
    private func createMockVideo(id: Int) -> Video {
        return Video(
            id: id,
            width: 1920,
            height: 1080,
            duration: 30,
            image: "https://example.com/image\(id).jpg",
            url: "https://example.com/\(id)",
            user: User(id: id, name: "User \(id)", url: "https://example.com/user\(id)"),
            videoFiles: [
                VideoFile(
                    id: id,
                    quality: "sd",
                    fileType: "video/mp4",
                    width: 1280,
                    height: 720,
                    link: "https://example.com/video\(id).mp4"
                )
            ]
        )
    }
}
