# Weel iOS Prototype App

This app is an experimental application designed to test and validate core functionalities for a future full-scale iOS project.

# Features

### 📍 Navigation & Map Integration

Search for POIs and display routes and navigation using Mapbox.

### 🎥 Video Recording & Playback

Back camera footage is recorded for the duration of navigation. The videos are saved locally in file storage and displayed viewable via the **Trips** paage.

# Technologies Used

- Swift & SwiftUI – For a modern, declarative UI.
- AVFoundation – For video recording and playback.
- Mapbox SDK
- UserDefaults & FileManager – To persist user data and video files.

# Installation

1. Clone the repository:
```git clone https://github.com/your-repo/ios-prototype.git```
2. Open iOSPrototype.xcodeproj in Xcode.
3. Connect to a physical device. (Mapbox navigation uses the **live** location source which relies on a device).
4. Build and run the app.

# How It Works

1. Search for a POI/Address and select it to kick off the search for routes.
2. Once routes have been retrieved, you can view the routes on the map as well as a modal sheet that presents each route with an ETA.
3. Tapping **Go** on the row of the route you want to proceed with will begin navigation which is a full screen prebuilt UI handled directly by Mapbox.
4. Once you begin navigation, the camera feed begins recording in the background. It will continue recording until navigation is complete.
5. Once navigation is dismissed (via the X button on the button right), recording stops and the video is saved to User Defaults.
6. Videos can be played back as well as deleted via the **Trips** page.

# Future improvements
- Video Processing: Improve video recording/saving/deleting UX. Mostly barebones as of right now.
- Compression and handling memory: No considerations for video size being saved.
