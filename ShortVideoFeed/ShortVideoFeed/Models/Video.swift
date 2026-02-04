//
//  Video.swift
//  ShortVideoFeed
//
//  Created by Tes on 02/02/2026.
//

import Foundation

// MARK: - Video Model
struct Video: Identifiable, Codable {
    let id: Int?
    let width: Int?
    let height: Int?
    let duration: Int?
    let image: String?
    let url: String?
    let user: User?
    let videoFiles: [VideoFile]?
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, duration, image, url, user
        case videoFiles = "video_files"
    }
    
    // Computed properties for convenience
    var videoURL: URL? {
        // Prefer SD quality for faster loading
        guard let videoFiles else { return nil }

        let sdFile = videoFiles.first { file in
            file.quality == "sd" && file.fileType == "video/mp4"
        }
        
        // Fallback to HD if SD not available
        let hdFile = videoFiles.first { file in
            file.quality == "hd" && file.fileType == "video/mp4"
        }
        
        // Use any MP4 file as last resort
        let anyMP4 = videoFiles.first { file in
            file.fileType == "video/mp4"
        }
        
        let selectedFile = sdFile ?? hdFile ?? anyMP4
        
        guard let link = selectedFile?.link else { return nil }
        return URL(string: link)
    }
    
    var thumbnailURL: URL? {
        guard let image else { return nil }
        return URL(string: image)
    }
    
    var displayDuration: String {
        let duration = duration ?? 0
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - VideoFile Model
struct VideoFile: Codable {
    let id: Int?
    let quality: String?
    let fileType: String?
    let width: Int?
    let height: Int?
    let link: String
    
    enum CodingKeys: String, CodingKey {
        case id, quality, width, height, link
        case fileType = "file_type"
    }
}
