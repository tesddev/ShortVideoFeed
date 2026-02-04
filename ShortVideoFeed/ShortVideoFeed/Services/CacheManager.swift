//
//  CacheManager.swift
//  ShortVideoFeed
//
//  Created by Tes on 02/02/2026.
//

import Foundation
import AVFoundation

// MARK: - Cache Manager
class CacheManager {
    static let shared = CacheManager()
    
    private let urlCache: URLCache
    
    init() {
        // Configure URL cache for video files
        // 100 MB disk cache, 20 MB memory cache
        urlCache = URLCache(
            memoryCapacity: 20 * 1024 * 1024,
            diskCapacity: 100 * 1024 * 1024,
            diskPath: "video_cache"
        )
        URLCache.shared = urlCache
    }
    
    // MARK: - Asset Caching
    // Create a new AVAsset with caching enabled
    func cachedAsset(for url: URL) -> AVAsset {
        // AVURLAsset will use URLCache automatically
        let asset = AVURLAsset(url: url, options: [
            AVURLAssetPreferPreciseDurationAndTimingKey: false
        ])
        return asset
    }
    
    // MARK: - Clear Cache
    func clearCache() {
        urlCache.removeAllCachedResponses()
    }
    
    // MARK: - Cache Statistics
    func cacheSize() -> Int {
        return urlCache.currentDiskUsage
    }
}
