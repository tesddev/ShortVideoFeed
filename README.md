# ShortVideoFeed

A TikTok-style vertical video feed app built with SwiftUI, featuring video playback, offline support, and user profile management.

### Video Demo

https://github.com/user-attachments/assets/24284b32-7bb1-4d01-bcbb-d405532c7553

[Alternatively, you can see demo here](https://drive.google.com/file/d/1O_JwHLM_p92TPPaQ-F4A6v4BFwfawaFd/view?usp=drive_link)

## 🚀 Setup Steps

### Prerequisites
* **Xcode 15.0** or later
* **iOS 17.0+** deployment target
* **Pexels API Key** (Get it free at [pexels.com/api/](https://www.pexels.com/api/))

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ShortVideoFeed
   ```

2. **Configure API Key**
* Create a new swift file and add the following code:

```swift
struct AppConstants {
    static let apiKey = "YOUR_PEXELS_API_KEY"
}
```

* Replace `YOUR_PEXELS_API_KEY` with your actual Pexels API key:


3. **Open the project**
```bash
open ShortVideoFeed.xcodeproj

```


4. **Build and Run**
* Select your target device/simulator.
* Press **Cmd + R** to build and run.
* Press **Cmd + U** to run tests.

---

## 🏗️ Architectural Overview

### Architecture Pattern: MVVM + Clean Architecture

The app follows the MVVM (Model-View-ViewModel) pattern with a clear separation of concerns:

```text
┌─────────────────────────────────────────────────┐
│                Views (SwiftUI)                  │
│  - VideoFeedView                                │
│  - ProfileView                                  │
│  - VideoPlayerView                              │
└────────────────┬────────────────────────────────┘
                 │ @StateObject / @ObservedObject
┌────────────────▼────────────────────────────────┐
│               ViewModels                        │
│  - VideoFeedViewModel                           │
│  - ProfileViewModel                             │
│  - VideoPlayerViewModel                         │
└────────────────┬────────────────────────────────┘
                 │ Uses
┌────────────────▼────────────────────────────────┐
│               Services                          │
│  - PexelsAPIService (Network)                   │
│  - CacheManager (Video caching)                 │
│  - LikeStorageService (Persistence)             │
└────────────────┬────────────────────────────────┘
                 │ Operates on
┌────────────────▼────────────────────────────────┐
│               Models                            │
│  - Video                                        │
│  - VideoFile                                    │
│  - User                                         │
└─────────────────────────────────────────────────┘
```

### Key Components

1. **Models (`Models/`)**
* `Video.swift`: Core video data model conforming to `Codable`.
* `User.swift`: User/creator information.
* `PexelsResponse.swift`: API response wrapper.


2. **Views (`Views/`)**
* `ContentView.swift`: Main tab navigation.
* `VideoFeedView.swift`: Vertical scrolling video feed.
* `VideoPlayerView.swift`: Individual video player with `AVPlayer`.
* `ProfileView.swift`: User profile with video grid.
* `VideoOverlayView.swift`: UI overlays (username, buttons, counts).


3. **ViewModels (`ViewModels/`)**
* `VideoFeedViewModel.swift`: Manages feed state, video fetching, and pagination.
* `ProfileViewModel.swift`: Handles profile data and user videos.
* `VideoPlayerViewModel.swift`: Controls video playback lifecycle.


4. **Services (`Services/`)**
* `PexelsAPIService.swift`: Network layer for Pexels API.
* `CacheManager.swift`: Video file caching with `URLCache`.
* `LikeStorageService.swift`: `UserDefaults`-based persistence for likes.

---

## 🛠️ Design Decisions

### Video Playback

* **AVFoundation:** Uses `AVPlayer` for robust video playback.
* **Resource Management:** Only 3 players are active at once (current + adjacent neighbors).
* **Preloading:** Automatically loads adjacent videos for smooth, zero-lag scrolling.
* **Cleanup:** Automatic player deallocation when scrolling away to save memory.

### Feed Implementation

* **TabView with PageTabViewStyle:** Utilizes native SwiftUI paging for a high-performance "swipe" feel.
* **Lazy Loading:** Videos are loaded on-demand rather than fetching all 200 at once.
* **Visibility Detection:** Players only play when they are the primary visible element.

### Caching Strategy

* **URLCache:** Leverages the system cache for efficient video file handling.
* **Limits:** 100MB Disk limit / 20MB Memory limit with automatic cleanup.

---

## 🎯 Feature Implementation

### Video Feed

* [x] Full-screen vertical feed
* [x] Swipe up/down navigation
* [x] Autoplay visible video
* [x] Pause/stop on scroll away
* [x] Smooth scrolling performance
* [x] Loading & Error states with retry

### Video Overlay UI

* [x] Tappable Creator username (leads to profile)
* [x] Video caption/title
* [x] Like button with local persistence
* [x] Comment & Share buttons (UI only)

### Profile Page

* [x] Accessible via username or tab bar
* [x] Avatar placeholder & Username display
* [x] Statistical counters (Video count, Total likes)
* [x] Responsive video grid layout
* [x] Tap-to-play functionality

### Testing

* [x] Unit tests for JSON parsing
* [x] Unit tests for `VideoFeedViewModel`
* [x] Unit tests for `LikeStorageService`
* [x] Mock services for isolated testing

---

## 📊 Performance Optimizations

1. **Memory Management:** Maximum 3 active `AVPlayers` and automatic deallocation.
2. **Network Efficiency:** Paginated API requests (80 videos per page) and response caching.
3. **UI Performance:** `LazyVStack` and `GeometryReader` for efficient visibility detection.

---

## ⚠️ Known Limitations & Tradeoffs

| Feature | Limitation | Decision/Reasoning |
| --- | --- | --- |
| **Video Quality** | Uses SD (Medium) quality. | Prioritized faster loading over high-def for tech test. |
| **Offline Mode** | Opportunistic caching only. | No explicit download feature; kept architecture simple. |
| **Persistence** | `UserDefaults`. | Efficient for small data; `CoreData` was overkill for likes only. |
| **Paging** | `TabView`. | Used for native feel, despite less control over preloading. |

---

## 🚧 Future Improvements (With More Time)

1. **Enhanced Player:** Add seek controls, volume toggles, and Haptic feedback.
2. **Better Caching:** Implement a custom `ResourceLoader` for progressive video loading.
3. **Social:** Integrate actual share sheets and a real-time commenting backend.
4. **Architecture:** Move to a Modular architecture using Swift Package Manager (SPM).

---

## 🧪 Testing

Run tests via Xcode (**Cmd + U**) or via command line:

```bash
xcodebuild test -project ShortVideoFeed.xcodeproj -scheme ShortVideoFeed -destination 'platform=iOS Simulator,name=iPhone 15'

```

---

## 📄 License

This is a technical project built with ❤️ using SwiftUI and AVFoundation.
