//
//  VideoPlayerView.swift
//  ShortVideoFeed
//
//  Created by Tes on 02/02/2026.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let video: Video
    let isCurrentVideo: Bool
    let onUsernameTap: () -> Void
    let onLikeTap: () -> Void
    let getLikeCount: () -> Int
    let isLiked: () -> Bool
    
    @StateObject private var playerViewModel = VideoPlayerViewModel()
    @State private var likeCount: Int = 0
    @State private var liked: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Video Player
            if let player = playerViewModel.player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
                    .disabled(true) // Disable default controls
            }
            
            // Loading indicator
            if playerViewModel.isBuffering {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }
            
            // Error state
            if playerViewModel.hasError {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.yellow)
                    
                    Text("Failed to load video")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    if let errorMessage = playerViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.white.opacity(0.8))
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Button(action: {
                        setupPlayer()
                    }) {
                        Text("Retry")
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(width: 100, height: 40)
                            .background(Color.white)
                            .cornerRadius(20)
                    }
                }
            }
            
            // Video overlay UI
            if !playerViewModel.hasError {
                VideoOverlayView(
                    video: video,
                    likeCount: likeCount,
                    isLiked: liked,
                    onUsernameTap: onUsernameTap,
                    onLikeTap: {
                        liked.toggle()
                        likeCount += liked ? 1 : -1
                        onLikeTap()
                    }
                )
            }
        }
        .onAppear {
            setupPlayer()
            updateLikeState()
        }
        .onDisappear {
            playerViewModel.cleanup()
        }
        .onChange(of: isCurrentVideo) { oldValue, newValue in
            if newValue {
                playerViewModel.play()
            } else {
                playerViewModel.pause()
            }
        }
    }
    
    private func setupPlayer() {
        guard let videoURL = video.videoURL else { return }
        playerViewModel.setupPlayer(with: videoURL)
        
        if isCurrentVideo {
            playerViewModel.play()
        }
    }
    
    private func updateLikeState() {
        likeCount = getLikeCount()
        liked = isLiked()
    }
}

// MARK: - Preview
#Preview {
    VideoPlayerView(
        video: Video(
            id: 1,
            width: 1080,
            height: 1920,
            duration: 30,
            image: "https://example.com/image.jpg",
            url: "https://example.com",
            user: User(id: 1, name: "Test User", url: "https://example.com"),
            videoFiles: [
                VideoFile(
                    id: 1,
                    quality: "sd",
                    fileType: "video/mp4",
                    width: 720,
                    height: 1280,
                    link: "https://example.com/video.mp4"
                )
            ]
        ),
        isCurrentVideo: true,
        onUsernameTap: {},
        onLikeTap: {},
        getLikeCount: { 1234 },
        isLiked: { false }
    )
}
