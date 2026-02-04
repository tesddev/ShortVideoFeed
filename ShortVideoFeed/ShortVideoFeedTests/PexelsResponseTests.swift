//
//  PexelsResponseTests.swift
//  ShortVideoFeedTests
//
//  Created by Tes on 02/02/2026.
//

import XCTest
@testable import ShortVideoFeed

//final class PexelsResponseTests: XCTestCase {
//    
//    // MARK: - Test JSON Parsing
//    
//    func testPexelsResponseDecoding() throws {
//        // Given: Valid JSON response
//        let jsonString = """
//        {
//            "page": 1,
//            "per_page": 80,
//            "total_results": 8000,
//            "url": "https://api.pexels.com/videos/search?query=people&per_page=80&page=1",
//            "videos": [
//                {
//                    "id": 123,
//                    "width": 1920,
//                    "height": 1080,
//                    "duration": 30,
//                    "image": "https://example.com/image.jpg",
//                    "url": "https://example.com/video",
//                    "user": {
//                        "id": 1,
//                        "name": "John Doe",
//                        "url": "https://example.com/user"
//                    },
//                    "video_files": [
//                        {
//                            "id": 1,
//                            "quality": "sd",
//                            "file_type": "video/mp4",
//                            "width": 1280,
//                            "height": 720,
//                            "link": "https://example.com/video.mp4"
//                        }
//                    ]
//                }
//            ]
//        }
//        """
//        
//        let jsonData = jsonString.data(using: .utf8)!
//        
//        // When: Decoding JSON
//        let decoder = JSONDecoder()
//        let response = try decoder.decode(PexelsResponse.self, from: jsonData)
//        
//        // Then: Verify decoded values
//        XCTAssertEqual(response.page, 1)
//        XCTAssertEqual(response.perPage, 80)
//        XCTAssertEqual(response.totalResults, 8000)
//        XCTAssertEqual(response.videos?.count, 1)
//        
//        // Verify video
//        let video = response.videos?[0]
//        XCTAssertEqual(video.id, 123)
//        XCTAssertEqual(video.width, 1920)
//        XCTAssertEqual(video.height, 1080)
//        XCTAssertEqual(video.duration, 30)
//        
//        // Verify user
//        XCTAssertEqual(video.user?.id, 1)
//        XCTAssertEqual(video.user?.name, "John Doe")
//        XCTAssertEqual(video.user?.username, "@john_doe")
//        
//        // Verify video files
//        XCTAssertEqual(video.videoFiles?.count, 1)
//        XCTAssertEqual(video.videoFiles[0].quality, "sd")
//        XCTAssertEqual(video.videoFiles[0].fileType, "video/mp4")
//    }
//    
//    func testVideoURLSelection() throws {
//        // Given: Video with multiple quality options
//        let video = Video(
//            id: 1,
//            width: 1920,
//            height: 1080,
//            duration: 30,
//            image: "https://example.com/image.jpg",
//            url: "https://example.com",
//            user: User(id: 1, name: "Test User", url: "https://example.com"),
//            videoFiles: [
//                VideoFile(id: 1, quality: "hd", fileType: "video/mp4", width: 1920, height: 1080, link: "https://example.com/hd.mp4"),
//                VideoFile(id: 2, quality: "sd", fileType: "video/mp4", width: 1280, height: 720, link: "https://example.com/sd.mp4"),
//                VideoFile(id: 3, quality: "hd", fileType: "video/webm", width: 1920, height: 1080, link: "https://example.com/hd.webm")
//            ]
//        )
//        
//        // When: Getting video URL
//        let videoURL = video.videoURL
//        
//        // Then: Should prefer SD MP4
//        XCTAssertNotNil(videoURL)
//        XCTAssertTrue(videoURL?.absoluteString.contains("sd.mp4") ?? false)
//    }
//    
//    func testVideoURLFallbackToHD() throws {
//        // Given: Video with only HD option
//        let video = Video(
//            id: 1,
//            width: 1920,
//            height: 1080,
//            duration: 30,
//            image: "https://example.com/image.jpg",
//            url: "https://example.com",
//            user: User(id: 1, name: "Test User", url: "https://example.com"),
//            videoFiles: [
//                VideoFile(id: 1, quality: "hd", fileType: "video/mp4", width: 1920, height: 1080, link: "https://example.com/hd.mp4")
//            ]
//        )
//        
//        // When: Getting video URL
//        let videoURL = video.videoURL
//        
//        // Then: Should use HD
//        XCTAssertNotNil(videoURL)
//        XCTAssertTrue(videoURL?.absoluteString.contains("hd.mp4") ?? false)
//    }
//    
//    func testUserUsernameGeneration() {
//        // Given: User with name
//        let user = User(id: 1, name: "John Doe", url: "https://example.com")
//        
//        // When: Getting username
//        let username = user.username
//        
//        // Then: Should format correctly
//        XCTAssertEqual(username, "@john_doe")
//    }
//    
//    func testVideoDisplayDuration() {
//        // Given: Video with duration in seconds
//        let video = Video(
//            id: 1,
//            width: 1920,
//            height: 1080,
//            duration: 125, // 2 minutes 5 seconds
//            image: "https://example.com/image.jpg",
//            url: "https://example.com",
//            user: User(id: 1, name: "Test User", url: "https://example.com"),
//            videoFiles: []
//        )
//        
//        // When: Getting display duration
//        let duration = video.displayDuration
//        
//        // Then: Should format as MM:SS
//        XCTAssertEqual(duration, "2:05")
//    }
//    
//    func testInvalidJSONDecoding() {
//        // Given: Invalid JSON
//        let jsonString = """
//        {
//            "invalid": "data"
//        }
//        """
//        
//        let jsonData = jsonString.data(using: .utf8)!
//        
//        // When/Then: Decoding should throw error
//        let decoder = JSONDecoder()
//        XCTAssertThrowsError(try decoder.decode(PexelsResponse.self, from: jsonData))
//    }
//}


import XCTest
@testable import ShortVideoFeed

final class PexelsResponseTests: XCTestCase {
    
    // MARK: - Test JSON Parsing
    
    func testPexelsResponseDecoding() throws {
        // Given: Valid JSON response
        let jsonString = """
        {
            "page": 1,
            "per_page": 80,
            "total_results": 8000,
            "url": "https://api.pexels.com/videos/search?query=people&per_page=80&page=1",
            "videos": [
                {
                    "id": 123,
                    "width": 1920,
                    "height": 1080,
                    "duration": 30,
                    "image": "https://example.com/image.jpg",
                    "url": "https://example.com/video",
                    "user": {
                        "id": 1,
                        "name": "John Doe",
                        "url": "https://example.com/user"
                    },
                    "video_files": [
                        {
                            "id": 1,
                            "quality": "sd",
                            "file_type": "video/mp4",
                            "width": 1280,
                            "height": 720,
                            "link": "https://example.com/video.mp4"
                        }
                    ]
                }
            ]
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        
        // When: Decoding JSON
        let decoder = JSONDecoder()
        let response = try decoder.decode(PexelsResponse.self, from: jsonData)
        
        // Then: Verify decoded values (with optional unwrapping)
        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.perPage, 80)
        XCTAssertEqual(response.totalResults, 8000)
        XCTAssertEqual(response.videos?.count, 1)
        
        // Verify video (safely unwrap optional)
        guard let videos = response.videos, let video = videos.first else {
            XCTFail("Videos should not be nil")
            return
        }
        
        XCTAssertEqual(video.id, 123)
        XCTAssertEqual(video.width, 1920)
        XCTAssertEqual(video.height, 1080)
        XCTAssertEqual(video.duration, 30)
        
        // Verify user
        XCTAssertEqual(video.user?.id, 1)
        XCTAssertEqual(video.user?.name, "John Doe")
        XCTAssertEqual(video.user?.username, "@john_doe")
        
        // Verify video files
        XCTAssertEqual(video.videoFiles?.count, 1)
        XCTAssertEqual(video.videoFiles?.first?.quality, "sd")
        XCTAssertEqual(video.videoFiles?.first?.fileType, "video/mp4")
    }
    
    func testPexelsResponseDecodingWithMissingOptionalFields() throws {
        // Given: JSON with minimal required fields
        let jsonString = """
        {
            "videos": [
                {
                    "video_files": [
                        {
                            "link": "https://example.com/video.mp4"
                        }
                    ]
                }
            ]
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        
        // When: Decoding JSON
        let decoder = JSONDecoder()
        let response = try decoder.decode(PexelsResponse.self, from: jsonData)
        
        // Then: Should decode successfully with nil optionals
        XCTAssertNil(response.page)
        XCTAssertNil(response.perPage)
        XCTAssertNil(response.totalResults)
        XCTAssertNotNil(response.videos)
        
        guard let video = response.videos?.first else {
            XCTFail("Videos should contain at least one video")
            return
        }
        
        XCTAssertNil(video.id)
        XCTAssertNil(video.user)
        XCTAssertNotNil(video.videoFiles)
    }
    
    func testVideoURLSelection() throws {
        // Given: Video with multiple quality options
        let video = Video(
            id: 1,
            width: 1920,
            height: 1080,
            duration: 30,
            image: "https://example.com/image.jpg",
            url: "https://example.com",
            user: User(id: 1, name: "Test User", url: "https://example.com"),
            videoFiles: [
                VideoFile(id: 1, quality: "hd", fileType: "video/mp4", width: 1920, height: 1080, link: "https://example.com/hd.mp4"),
                VideoFile(id: 2, quality: "sd", fileType: "video/mp4", width: 1280, height: 720, link: "https://example.com/sd.mp4"),
                VideoFile(id: 3, quality: "hd", fileType: "video/webm", width: 1920, height: 1080, link: "https://example.com/hd.webm")
            ]
        )
        
        // When: Getting video URL
        let videoURL = video.videoURL
        
        // Then: Should prefer SD MP4
        XCTAssertNotNil(videoURL)
        XCTAssertTrue(videoURL?.absoluteString.contains("sd.mp4") ?? false)
    }
    
    func testVideoURLFallbackToHD() throws {
        // Given: Video with only HD option
        let video = Video(
            id: 1,
            width: 1920,
            height: 1080,
            duration: 30,
            image: "https://example.com/image.jpg",
            url: "https://example.com",
            user: User(id: 1, name: "Test User", url: "https://example.com"),
            videoFiles: [
                VideoFile(id: 1, quality: "hd", fileType: "video/mp4", width: 1920, height: 1080, link: "https://example.com/hd.mp4")
            ]
        )
        
        // When: Getting video URL
        let videoURL = video.videoURL
        
        // Then: Should use HD
        XCTAssertNotNil(videoURL)
        XCTAssertTrue(videoURL?.absoluteString.contains("hd.mp4") ?? false)
    }
    
    func testVideoURLWithNilVideoFiles() {
        // Given: Video with nil videoFiles
        let video = Video(
            id: 1,
            width: 1920,
            height: 1080,
            duration: 30,
            image: "https://example.com/image.jpg",
            url: "https://example.com",
            user: User(id: 1, name: "Test User", url: "https://example.com"),
            videoFiles: nil
        )
        
        // When: Getting video URL
        let videoURL = video.videoURL
        
        // Then: Should return nil
        XCTAssertNil(videoURL)
    }
    
    func testVideoURLWithEmptyVideoFiles() {
        // Given: Video with empty videoFiles array
        let video = Video(
            id: 1,
            width: 1920,
            height: 1080,
            duration: 30,
            image: "https://example.com/image.jpg",
            url: "https://example.com",
            user: User(id: 1, name: "Test User", url: "https://example.com"),
            videoFiles: []
        )
        
        // When: Getting video URL
        let videoURL = video.videoURL
        
        // Then: Should return nil
        XCTAssertNil(videoURL)
    }
    
    func testUserUsernameGeneration() {
        // Given: User with name
        let user = User(id: 1, name: "John Doe", url: "https://example.com")
        
        // When: Getting username
        let username = user.username
        
        // Then: Should format correctly
        XCTAssertEqual(username, "@john_doe")
    }
    
    func testUserUsernameWithNilName() {
        // Given: User with nil name
        let user = User(id: 1, name: nil, url: "https://example.com")
        
        // When: Getting username
        let username = user.username
        
        // Then: Should return @ prefix only
        XCTAssertEqual(username, "@")
    }
    
    func testVideoDisplayDuration() {
        // Given: Video with duration in seconds
        let video = Video(
            id: 1,
            width: 1920,
            height: 1080,
            duration: 125, // 2 minutes 5 seconds
            image: "https://example.com/image.jpg",
            url: "https://example.com",
            user: User(id: 1, name: "Test User", url: "https://example.com"),
            videoFiles: []
        )
        
        // When: Getting display duration
        let duration = video.displayDuration
        
        // Then: Should format as MM:SS
        XCTAssertEqual(duration, "2:05")
    }
    
    func testVideoDisplayDurationWithNilDuration() {
        // Given: Video with nil duration
        let video = Video(
            id: 1,
            width: 1920,
            height: 1080,
            duration: nil,
            image: "https://example.com/image.jpg",
            url: "https://example.com",
            user: User(id: 1, name: "Test User", url: "https://example.com"),
            videoFiles: []
        )
        
        // When: Getting display duration
        let duration = video.displayDuration
        
        // Then: Should format as 0:00
        XCTAssertEqual(duration, "0:00")
    }
    
    func testVideoThumbnailURL() {
        // Given: Video with image URL
        let video = Video(
            id: 1,
            width: 1920,
            height: 1080,
            duration: 30,
            image: "https://example.com/image.jpg",
            url: "https://example.com",
            user: User(id: 1, name: "Test User", url: "https://example.com"),
            videoFiles: []
        )
        
        // When: Getting thumbnail URL
        let thumbnailURL = video.thumbnailURL
        
        // Then: Should return valid URL
        XCTAssertNotNil(thumbnailURL)
        XCTAssertEqual(thumbnailURL?.absoluteString, "https://example.com/image.jpg")
    }
    
    func testVideoThumbnailURLWithNilImage() {
        // Given: Video with nil image
        let video = Video(
            id: 1,
            width: 1920,
            height: 1080,
            duration: 30,
            image: nil,
            url: "https://example.com",
            user: User(id: 1, name: "Test User", url: "https://example.com"),
            videoFiles: []
        )
        
        // When: Getting thumbnail URL
        let thumbnailURL = video.thumbnailURL
        
        // Then: Should return nil
        XCTAssertNil(thumbnailURL)
    }
    
    func testInvalidJSONDecoding() {
        // Given: Invalid JSON
        let jsonString = """
        {
            "invalid": "data"
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        
        // When/Then: Decoding should succeed but with nil/empty values
        let decoder = JSONDecoder()
        let response = try? decoder.decode(PexelsResponse.self, from: jsonData)
        
        // Should decode successfully with all optionals as nil
        XCTAssertNotNil(response)
        XCTAssertNil(response?.page)
        XCTAssertNil(response?.videos)
    }
    
    func testCompletelyEmptyJSON() throws {
        // Given: Empty JSON object
        let jsonString = "{}"
        let jsonData = jsonString.data(using: .utf8)!
        
        // When: Decoding JSON
        let decoder = JSONDecoder()
        let response = try decoder.decode(PexelsResponse.self, from: jsonData)
        
        // Then: Should decode successfully with all optionals as nil
        XCTAssertNil(response.page)
        XCTAssertNil(response.perPage)
        XCTAssertNil(response.totalResults)
        XCTAssertNil(response.videos)
        XCTAssertNil(response.nextPage)
    }
    
    func testVideoFileWithOnlyRequiredLink() throws {
        // Given: VideoFile with only link (required field)
        let jsonString = """
        {
            "link": "https://example.com/video.mp4"
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        
        // When: Decoding VideoFile
        let decoder = JSONDecoder()
        let videoFile = try decoder.decode(VideoFile.self, from: jsonData)
        
        // Then: Should decode with link and nil optionals
        XCTAssertEqual(videoFile.link, "https://example.com/video.mp4")
        XCTAssertNil(videoFile.id)
        XCTAssertNil(videoFile.quality)
        XCTAssertNil(videoFile.fileType)
        XCTAssertNil(videoFile.width)
        XCTAssertNil(videoFile.height)
    }
    
    func testUserProfileURL() {
        // Given: User with valid URL
        let user = User(id: 1, name: "Test", url: "https://example.com/user")
        
        // When: Getting profile URL
        let profileURL = user.profileURL
        
        // Then: Should return valid URL
        XCTAssertNotNil(profileURL)
        XCTAssertEqual(profileURL?.absoluteString, "https://example.com/user")
    }
    
    func testUserProfileURLWithNilURL() {
        // Given: User with nil URL
        let user = User(id: 1, name: "Test", url: nil)
        
        // When: Getting profile URL
        let profileURL = user.profileURL
        
        // Then: Should return nil (URL("") returns nil)
        XCTAssertNil(profileURL)
    }
}
