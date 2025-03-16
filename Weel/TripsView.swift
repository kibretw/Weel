//
//  ContentView.swift
//  Weel
//
//  Created by Kibret Woldemichael on 3/6/25.
//

import SwiftUI

struct TripsView: View {
    @EnvironmentObject private var videoManager: VideoManager

    var body: some View {
        NavigationStack {
            VStack {
                VideoGridView(videoManager: videoManager)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Trips")
        }
        .onAppear {
            videoManager.getSavedVideos()
        }
    }
}

#Preview {
    TripsView()
}

import AVKit

struct VideoGridView: View {
    @ObservedObject var videoManager: VideoManager
    
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach($videoManager.videos, id: \.self) { video in
                    ZStack {
                        
                        VideoThumbnailView(video: video.wrappedValue)
                            .frame(height: 200)
                            .clipShape(.rect(cornerRadius: 8))

                        VStack {
                            HStack {
                                Spacer()
                                
                                Menu {
                                    Button("Delete", role: .destructive) {
                                        videoManager.removeVideo(filename: video.wrappedValue.lastPathComponent)
                                    }
                                } label: {
                                    Circle()
                                        .fill(.gray)
                                        .frame(width: 30, height: 30)
                                        .overlay {
                                            Image(systemName: "ellipsis")
//                                                .font(.title3)
                                                .foregroundColor(.blue)
                                                .padding()
                                        }
                                }
                            }
                            .padding(8)
                            
                            Spacer()
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct VideoThumbnailView: View {
    let video: URL
    @State private var showPlayer = false

    var body: some View {
        ZStack {
            if let thumbnail = getThumbnailImage(for: video) {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.gray
            }
        }
        .onTapGesture {
            showPlayer = true
        }
        .fullScreenCover(isPresented: $showPlayer) {
            ZStack(alignment: .topLeading) {
                VideoPlayer(player: AVPlayer(url: video))
                    .edgesIgnoringSafeArea(.all)
                
                Button(action: {
                    showPlayer = false
                }) {
                    Image(systemName: "xmark")
                        .font(.largeTitle)
                        .foregroundStyle(.gray)
                        .padding()
                }
                .padding([.leading, .top])
            }
        }
    }

    private func getThumbnailImage(for url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true

        do {
            let cgImage = try assetImageGenerator.copyCGImage(at: .zero, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}
