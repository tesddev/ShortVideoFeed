//
//  VideoFeedView.swift
//  ShortVideoFeed
//
//  Created by Tes on 02/02/2026.
//

import SwiftUI

struct VideoFeedView: View {
    @ObservedObject var viewModel: VideoFeedViewModel
    @State private var selectedUserId: Int?
    @State private var showProfile = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.videos.isEmpty {
                // Initial loading state
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    Text("Loading videos...")
                        .foregroundColor(.white)
                        .font(.headline)
                }
            } else if let errorMessage = viewModel.errorMessage, viewModel.videos.isEmpty {
                // Error state
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)
                    
                    Text("Oops!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(errorMessage)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button(action: {
                        Task {
                            await viewModel.retry()
                        }
                    }) {
                        Text("Retry")
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(width: 120, height: 44)
                            .background(Color.white)
                            .cornerRadius(22)
                    }
                }
                .padding()
            } else if viewModel.videos.isEmpty {
                // Empty state
                VStack(spacing: 20) {
                    Image(systemName: "video.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No videos available")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            } else {
                // Video feed
                TabView(selection: $viewModel.currentVideoIndex) {
                    ForEach(Array(viewModel.videos.enumerated()), id: \.element.id) { index, video in
                        VideoPlayerView(
                            video: video,
                            isCurrentVideo: viewModel.currentVideoIndex == index,
                            onUsernameTap: {
                                selectedUserId = video.user?.id ?? 0
                                showProfile = true
                            },
                            onLikeTap: {
                                _ = viewModel.toggleLike(for: video)
                            },
                            getLikeCount: {
                                viewModel.getLikeCount(for: video)
                            },
                            isLiked: {
                                viewModel.isLiked(video: video)
                            }
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()
                .onChange(of: viewModel.currentVideoIndex) { oldValue, newValue in
                    viewModel.updateCurrentIndex(newValue)
                }
            }
        }
        .task {
            if viewModel.videos.isEmpty {
                await viewModel.loadVideos()
            }
        }
        .sheet(isPresented: $showProfile) {
            if selectedUserId != nil {
                NavigationStack {
                    ProfileView(
                        viewModel: ProfileViewModel(),
                        allVideos: viewModel.videos
                    )
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showProfile = false
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    VideoFeedView(viewModel: VideoFeedViewModel())
}
