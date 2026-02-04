//
//  VideoPlayerViewModel.swift
//  ShortVideoFeed
//
//  Created by Tes on 02/02/2026.
//

import AVFoundation
import Combine

// MARK: - Video Player View Model
@MainActor
class VideoPlayerViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var isBuffering = true
    @Published var hasError = false
    @Published var errorMessage: String?
    
    var player: AVPlayer?
    private var timeObserver: Any?
    private var statusObserver: AnyCancellable?
    private let cacheManager: CacheManager
    
    init(cacheManager: CacheManager = .shared) {
        self.cacheManager = cacheManager
    }
    
    // MARK: - Setup Player
    func setupPlayer(with url: URL) {
        cleanup()
        
        // Check cache first
        let asset = cacheManager.cachedAsset(for: url)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        observePlayerStatus()
    }
    
    // MARK: - Playback Control
    func play() {
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func seek(to time: CMTime) {
        player?.seek(to: time)
    }
    
    // MARK: - Observer
    private func observePlayerStatus() {
        guard let player = player else { return }
        
        statusObserver = player.publisher(for: \.currentItem?.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                
                switch status {
                case .readyToPlay:
                    self.isBuffering = false
                    self.hasError = false
                    self.play()
                case .failed:
                    self.isBuffering = false
                    self.hasError = true
                    self.errorMessage = player.currentItem?.error?.localizedDescription ?? "Unknown error"
                case .unknown:
                    self.isBuffering = true
                default:
                    break
                }
            }
    }
    
    // MARK: - Cleanup
    func cleanup() {
        statusObserver?.cancel()
        statusObserver = nil
        
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        
        player?.pause()
        player = nil
        
        isPlaying = false
        isBuffering = true
        hasError = false
        errorMessage = nil
    }
    
    nonisolated private func cleanupSync() {
        Task { @MainActor in
            self.statusObserver?.cancel()
        }
    }
    
    deinit {
//        cleanupSync()
    }
}
