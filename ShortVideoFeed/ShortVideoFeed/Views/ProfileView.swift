//
//  ProfileView.swift
//  ShortVideoFeed
//
//  Created by Tes on 02/02/2026.
//

import SwiftUI
import _AVKit_SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    let allVideos: [Video]
    
    let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                ProfileHeaderView(viewModel: viewModel)
                
                // Stats
                ProfileStatsView(viewModel: viewModel)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                // Videos Grid
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(viewModel.userVideos) { video in
                        VideoThumbnailView(video: video)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.selectVideo(video)
                            }
                    }
                }
            }
            .padding(.top)
        }
        .background(Color.black)
        .onAppear {
            viewModel.loadProfileData(from: allVideos)
        }
        .fullScreenCover(isPresented: $viewModel.showVideoPlayer, onDismiss: {
            viewModel.closeVideoPlayer()
        }) {
            if let selectedVideo = viewModel.selectedVideo {
                FullScreenVideoPlayer(
                    video: selectedVideo,
                    onDismiss: {
                        viewModel.closeVideoPlayer()
                    }
                )
            }
        }
    }
}

// MARK: - Profile Header
struct ProfileHeaderView: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.purple, .pink, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                )
            
            // Username
            Text(viewModel.user.username)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Bio (optional)
            Text("Content creator • Video enthusiast")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Profile Stats
struct ProfileStatsView: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        HStack(spacing: 40) {
            StatView(count: viewModel.followingCount, label: "Following")
            StatView(count: viewModel.followersCount, label: "Followers")
            StatView(count: viewModel.totalLikes, label: "Likes")
        }
        .padding(.horizontal)
    }
}

struct StatView: View {
    let count: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(formatCount(count))
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    private func formatCount(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000.0)
        } else if count >= 1_000 {
            return String(format: "%.1fK", Double(count) / 1_000.0)
        } else {
            return "\(count)"
        }
    }
}

// MARK: - Video Thumbnail
struct VideoThumbnailView: View {
    let video: Video
    
    var body: some View {
        GeometryReader { geometry in
            AsyncImage(url: video.thumbnailURL) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            ProgressView()
                                .tint(.white)
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.width * 1.5)
                        .clipped()
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                @unknown default:
                    EmptyView()
                }
            }
        }
        .aspectRatio(2/3, contentMode: .fit)
    }
}

// MARK: - Full Screen Video Player
struct FullScreenVideoPlayer: View {
    let video: Video
    let onDismiss: () -> Void
    
    @StateObject private var playerViewModel = VideoPlayerViewModel()
    @State private var videoId: Int
    
    init(video: Video, onDismiss: @escaping () -> Void) {
        self.video = video
        self.onDismiss = onDismiss
        _videoId = State(initialValue: video.id ?? 0)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let player = playerViewModel.player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
                    .id(videoId)
            } else if playerViewModel.isBuffering {
                // Loading state
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    Text("Loading video...")
                        .foregroundColor(.white)
                        .font(.headline)
                }
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
                        setupAndPlay()
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
            
            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        playerViewModel.cleanup()
                        onDismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .onAppear {
            setupAndPlay()
        }
        .onDisappear {
            playerViewModel.cleanup()
        }
    }
    
    private func setupAndPlay() {
        guard let videoURL = video.videoURL else {
            print("❌ No video URL for video ID: \(video.id ?? 0)")
            return
        }
        
        print("▶️ Setting up video ID: \(video.id ?? 0) with URL: \(videoURL)")
        playerViewModel.setupPlayer(with: videoURL)
        
        // Small delay to ensure player is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            playerViewModel.play()
        }
    }
}

// MARK: - Preview
#Preview {
    ProfileView(
        viewModel: ProfileViewModel(),
        allVideos: []
    )
}
