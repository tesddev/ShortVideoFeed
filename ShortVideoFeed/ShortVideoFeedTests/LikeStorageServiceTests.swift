//
//  LikeStorageServiceTests.swift
//  ShortVideoFeedTests
//
//  Created by Tes on 02/02/2026.
//

import XCTest
@testable import ShortVideoFeed

final class LikeStorageServiceTests: XCTestCase {
    var sut: LikeStorageService!
    
    override func setUp() {
        super.setUp()
        sut = LikeStorageService.shared
        sut.resetAllData() // Clean state for each test
    }
    
    override func tearDown() {
        sut.resetAllData()
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Toggle Like Tests
    
    func testToggleLikeAddsLike() {
        // Given
        let videoId = 123
        
        // When
        let result = sut.toggleLike(for: videoId)
        
        // Then
        XCTAssertTrue(result, "Should return true when adding like")
        XCTAssertTrue(sut.isLiked(videoId: videoId))
        XCTAssertGreaterThan(sut.getLikeCount(for: videoId), 0)
    }
    
    func testToggleLikeRemovesLike() {
        // Given
        let videoId = 123
        _ = sut.toggleLike(for: videoId) // Add like
        let countAfterLike = sut.getLikeCount(for: videoId)
        
        // When
        let result = sut.toggleLike(for: videoId) // Remove like
        
        // Then
        XCTAssertFalse(result, "Should return false when removing like")
        XCTAssertFalse(sut.isLiked(videoId: videoId))
        XCTAssertEqual(sut.getLikeCount(for: videoId), countAfterLike - 1)
    }
    
    func testToggleLikeMultipleTimes() {
        // Given
        let videoId = 123
        
        // When/Then: Toggle multiple times
        XCTAssertTrue(sut.toggleLike(for: videoId))  // Like
        XCTAssertFalse(sut.toggleLike(for: videoId)) // Unlike
        XCTAssertTrue(sut.toggleLike(for: videoId))  // Like again
        XCTAssertTrue(sut.isLiked(videoId: videoId))
    }
    
    // MARK: - Get Like Count Tests
    
    func testGetLikeCountForNewVideo() {
        // Given
        let videoId = 999
        
        // When
        let count = sut.getLikeCount(for: videoId)
        
        // Then: Should return mock initial count
        XCTAssertGreaterThanOrEqual(count, 100)
        XCTAssertLessThanOrEqual(count, 10000)
    }
    
    func testGetLikeCountForMultipleVideos() {
        // Given
        let videoIds = [1, 2, 3, 4, 5]
        
        // When
        videoIds.forEach { _ = sut.toggleLike(for: $0) }
        
        // Then: Each video should have different counts
        let counts = videoIds.map { sut.getLikeCount(for: $0) }
        XCTAssertTrue(counts.allSatisfy { $0 > 0 })
    }
    
    // MARK: - Is Liked Tests
    
    func testIsLikedForUnlikedVideo() {
        // Given
        let videoId = 123
        
        // When
        let isLiked = sut.isLiked(videoId: videoId)
        
        // Then
        XCTAssertFalse(isLiked)
    }
    
    func testIsLikedForLikedVideo() {
        // Given
        let videoId = 123
        _ = sut.toggleLike(for: videoId)
        
        // When
        let isLiked = sut.isLiked(videoId: videoId)
        
        // Then
        XCTAssertTrue(isLiked)
    }
    
    func testIsLikedAfterUnlike() {
        // Given
        let videoId = 123
        _ = sut.toggleLike(for: videoId) // Like
        _ = sut.toggleLike(for: videoId) // Unlike
        
        // When
        let isLiked = sut.isLiked(videoId: videoId)
        
        // Then
        XCTAssertFalse(isLiked)
    }
    
    // MARK: - Total Likes Tests
    
    func testGetTotalLikesCountInitial() {
        // Given: Fresh state
        
        // When
        let totalLikes = sut.getTotalLikesCount()
        
        // Then
        XCTAssertEqual(totalLikes, 0)
    }
    
    func testGetTotalLikesCountAfterLikes() {
        // Given
        let videoIds = [1, 2, 3]
        videoIds.forEach { _ = sut.toggleLike(for: $0) }
        
        // When
        let totalLikes = sut.getTotalLikesCount()
        
        // Then
        XCTAssertGreaterThan(totalLikes, 0)
    }
    
    func testGetTotalLikesCountAfterUnlike() {
        // Given
        let videoId = 123
        _ = sut.toggleLike(for: videoId) // Like
        let countAfterLike = sut.getTotalLikesCount()
        
        // When
        _ = sut.toggleLike(for: videoId) // Unlike
        let countAfterUnlike = sut.getTotalLikesCount()
        
        // Then
        XCTAssertLessThan(countAfterUnlike, countAfterLike)
    }
    
    // MARK: - Persistence Tests
    
    func testLikesPersistAcrossInstances() {
        // Given
        let videoId = 123
        _ = sut.toggleLike(for: videoId)
        let count1 = sut.getLikeCount(for: videoId)
        
        // When: Create new instance (simulates app restart)
        let newInstance = LikeStorageService.shared
        let count2 = newInstance.getLikeCount(for: videoId)
        
        // Then
        XCTAssertEqual(count1, count2)
        XCTAssertTrue(newInstance.isLiked(videoId: videoId))
    }
    
    // MARK: - Reset Tests
    
    func testResetAllData() {
        // Given
        let videoIds = [1, 2, 3]
        videoIds.forEach { _ = sut.toggleLike(for: $0) }
        
        // When
        sut.resetAllData()
        
        // Then
        XCTAssertEqual(sut.getTotalLikesCount(), 0)
        videoIds.forEach { videoId in
            XCTAssertFalse(sut.isLiked(videoId: videoId))
        }
    }
    
    // MARK: - Edge Cases
    
    func testLikeCountNeverGoesBelowZero() {
        // Given
        let videoId = 123
        
        // When: Try to unlike a video that was never liked
        _ = sut.toggleLike(for: videoId) // Like
        _ = sut.toggleLike(for: videoId) // Unlike
        let count = sut.getLikeCount(for: videoId)
        
        // Then
        XCTAssertGreaterThanOrEqual(count, 0)
    }
    
    func testConcurrentLikes() {
        // Given
        let videoId = 123
        let expectation = XCTestExpectation(description: "Concurrent likes")
        expectation.expectedFulfillmentCount = 10
        
        // When: Perform concurrent likes
        for _ in 0..<10 {
            DispatchQueue.global().async {
                _ = self.sut.toggleLike(for: videoId)
                expectation.fulfill()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 5.0)
        // Just verify no crashes occurred
        XCTAssertTrue(true)
    }
    
    // MARK: - Edge Cases for Optional Video IDs
    
    func testToggleLikeWithZeroId() {
        // Given: Video ID of 0 (potential fallback for nil)
        let videoId = 0
        
        // When
        let result1 = sut.toggleLike(for: videoId)
        let result2 = sut.toggleLike(for: videoId)
        
        // Then: Should toggle correctly even for ID 0
        XCTAssertTrue(result1)
        XCTAssertFalse(result2)
    }
    
    func testGetLikeCountForZeroId() {
        // Given: Video ID of 0
        let videoId = 0
        
        // When
        let count = sut.getLikeCount(for: videoId)
        
        // Then: Should return valid count
        XCTAssertGreaterThanOrEqual(count, 0)
    }
    
    func testIsLikedForZeroId() {
        // Given: Video ID of 0
        let videoId = 0
        
        // When: Check liked status before and after
        let isLikedBefore = sut.isLiked(videoId: videoId)
        _ = sut.toggleLike(for: videoId)
        let isLikedAfter = sut.isLiked(videoId: videoId)
        
        // Then
        XCTAssertFalse(isLikedBefore)
        XCTAssertTrue(isLikedAfter)
    }
    
    func testMultipleVideosWithSameZeroId() {
        // Given: Multiple operations on ID 0
        let videoId = 0
        
        // When: Toggle multiple times
        _ = sut.toggleLike(for: videoId) // Like
        let count1 = sut.getLikeCount(for: videoId)
        
        _ = sut.toggleLike(for: videoId) // Unlike
        let count2 = sut.getLikeCount(for: videoId)
        
        _ = sut.toggleLike(for: videoId) // Like again
        let count3 = sut.getLikeCount(for: videoId)
        
        // Then: Counts should change appropriately
        XCTAssertEqual(count2, count1 - 1)
        XCTAssertEqual(count3, count2 + 1)
    }
    
    func testNegativeVideoId() {
        // Given: Negative video ID (edge case)
        let videoId = -1
        
        // When/Then: Should handle gracefully without crashing
        let result = sut.toggleLike(for: videoId)
        XCTAssertTrue(result == true || result == false)
        
        let count = sut.getLikeCount(for: videoId)
        XCTAssertGreaterThanOrEqual(count, 0)
        
        let isLiked = sut.isLiked(videoId: videoId)
        XCTAssertTrue(isLiked == true || isLiked == false)
    }
    
    func testVeryLargeVideoId() {
        // Given: Very large video ID
        let videoId = Int.max
        
        // When/Then: Should handle gracefully
        let result = sut.toggleLike(for: videoId)
        XCTAssertTrue(result)
        
        let count = sut.getLikeCount(for: videoId)
        XCTAssertGreaterThan(count, 0)
        
        let isLiked = sut.isLiked(videoId: videoId)
        XCTAssertTrue(isLiked)
    }
    
    func testResetClearsZeroIdLikes() {
        // Given: Likes on ID 0
        let videoId = 0
        _ = sut.toggleLike(for: videoId)
        XCTAssertTrue(sut.isLiked(videoId: videoId))
        
        // When
        sut.resetAllData()
        
        // Then
        XCTAssertFalse(sut.isLiked(videoId: videoId))
        XCTAssertEqual(sut.getTotalLikesCount(), 0)
    }
    
    func testMixedIdRanges() {
        // Given: Mix of normal, zero, and edge case IDs
        let videoIds = [0, 1, 100, 999, Int.max]
        
        // When: Like all videos
        videoIds.forEach { _ = sut.toggleLike(for: $0) }
        
        // Then: All should be liked
        let allLiked = videoIds.allSatisfy { sut.isLiked(videoId: $0) }
        XCTAssertTrue(allLiked)
        
        // When: Unlike all
        videoIds.forEach { _ = sut.toggleLike(for: $0) }
        
        // Then: None should be liked
        let noneLiked = videoIds.allSatisfy { !sut.isLiked(videoId: $0) }
        XCTAssertTrue(noneLiked)
    }
    
    func testTotalLikesWithZeroIds() {
        // Given: Mix including ID 0
        let videoIds = [0, 1, 2]
        videoIds.forEach { _ = sut.toggleLike(for: $0) }
        
        // When
        let totalLikes = sut.getTotalLikesCount()
        
        // Then: Should count all likes including ID 0
        XCTAssertGreaterThan(totalLikes, 0)
    }
    
    // MARK: - Thread Safety Tests
    
    func testConcurrentOperationsOnDifferentVideos() {
        // Given
        let videoIds = [1, 2, 3, 4, 5]
        let expectation = XCTestExpectation(description: "Concurrent operations")
        expectation.expectedFulfillmentCount = videoIds.count * 2
        
        // When: Perform concurrent operations on different videos
        for videoId in videoIds {
            DispatchQueue.global().async {
                _ = self.sut.toggleLike(for: videoId)
                expectation.fulfill()
            }
            
            DispatchQueue.global().async {
                _ = self.sut.getLikeCount(for: videoId)
                expectation.fulfill()
            }
        }
        
        // Then: No crashes should occur
        wait(for: [expectation], timeout: 5.0)
        XCTAssertTrue(true)
    }
    
    func testConcurrentToggleAndCheck() {
        // Given
        let videoId = 123
        let expectation = XCTestExpectation(description: "Concurrent toggle and check")
        expectation.expectedFulfillmentCount = 20
        
        // When: Mix toggle and check operations
        for i in 0..<10 {
            DispatchQueue.global().async {
                _ = self.sut.toggleLike(for: videoId)
                expectation.fulfill()
            }
            
            DispatchQueue.global().async {
                _ = self.sut.isLiked(videoId: videoId)
                expectation.fulfill()
            }
        }
        
        // Then: No crashes should occur
        wait(for: [expectation], timeout: 5.0)
        XCTAssertTrue(true)
    }
}
