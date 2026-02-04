//
//  PexelsResponse.swift
//  ShortVideoFeed
//
//  Created by Tes on 02/02/2026.
//

import Foundation

// MARK: - Pexels API Response
struct PexelsResponse: Codable {
    let page: Int?
    let perPage: Int?
    let videos: [Video]?
    let totalResults: Int?
    let nextPage: String?
    
    enum CodingKeys: String, CodingKey {
        case page, videos
        case perPage = "per_page"
        case totalResults = "total_results"
        case nextPage = "next_page"
    }
}
