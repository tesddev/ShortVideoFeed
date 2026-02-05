//
//  VideoOverlayView.swift
//  ShortVideoFeed
//
//  Created by Tes on 02/02/2026.
//

import SwiftUI

struct VideoOverlayView: View {
    let video: Video
    let likeCount: Int
    let isLiked: Bool
    let onUsernameTap: () -> Void
    let onLikeTap: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 0) {
                // Left side - User info and caption
                VStack(alignment: .leading, spacing: 12) {
                    Spacer()
                    
                    // Username
                    Button(action: onUsernameTap) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 20))
                                )
                            
                            Text(video.user?.username ?? "")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Caption (if available)
                    if let caption = video.user?.name, !caption.isEmpty {
                        Text(caption)
                            .font(.body)
                            .foregroundColor(.white)
                            .lineLimit(2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                
                // Right side - Action buttons
                VStack(spacing: 24) {
                    // Like button
                    ActionButton(
                        icon: isLiked ? "heart.fill" : "heart",
                        count: formatCount(likeCount),
                        color: isLiked ? .red : .white,
                        action: onLikeTap
                    )
                    
                    // Comment button
                    ActionButton(
                        icon: "message",
                        count: formatCount(Int.random(in: 10...500)),
                        color: .white,
                        action: {}
                    )
                    
                    // Share button
                    ActionButton(
                        icon: "arrowshape.turn.up.right",
                        count: formatCount(Int.random(in: 5...200)),
                        color: .white,
                        action: {}
                    )
                }
                .padding(.trailing, 16)
                .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
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

// MARK: - Action Button
struct ActionButton: View {
    let icon: String
    let count: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                    .frame(width: 48, height: 48)
                
                Text(count)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VideoOverlayView(
            video: Video(
                id: 1,
                width: 1080,
                height: 1920,
                duration: 30,
                image: "https://example.com/image.jpg",
                url: "https://example.com",
                user: User(id: 1, name: "Amazing Video Content", url: "https://example.com"),
                videoFiles: []
            ),
            likeCount: 12345,
            isLiked: true,
            onUsernameTap: {},
            onLikeTap: {}
        )
    }
}
