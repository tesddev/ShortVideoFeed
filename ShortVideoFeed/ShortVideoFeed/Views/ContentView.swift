//
//  ContentView.swift
//  ShortVideoFeed
//
//  Created by Tes on 02/02/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var feedViewModel = VideoFeedViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Feed Tab
            VideoFeedView(viewModel: feedViewModel)
                .tabItem {
                    Label("Feed", systemImage: "play.rectangle.fill")
                }
                .tag(0)
            
            // Profile Tab
            ProfileView(viewModel: profileViewModel, allVideos: feedViewModel.videos)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(1)
        }
        .tint(.white)
    }
}

#Preview {
    ContentView()
}
