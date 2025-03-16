//
//  MapButtons.swift
//  Weel
//
//  Created by Kibret Woldemichael on 3/15/25.
//

import SwiftUI
import MapboxMaps

struct MapButtons: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var videoManager: VideoManager
    @ObservedObject var viewModel: NavigationHomeViewModel
    
    @Binding var viewport: Viewport
    
    var body: some View {
        HStack {
            VStack {
                
                Button {
                    
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.appBlue)
                        .transition(.scale.animation(.easeOut))
                }
                .frame(width: 50, height: 50)
                .background(colorScheme == .dark ? Color.black : Color.appBackground)
                .clipShape(.circle)
                .overlay(
                    Circle().stroke(
                        colorScheme == .dark ? Color.tertiarySystemBackground : Color.white,
                        lineWidth: 1
                    )
                )
                
                Button {
                    withAnimation {
                        videoManager.showDashCam.toggle()
                    }
                } label: {
                    Image(systemName: videoManager.showDashCam ? "video.fill" : "video.slash.fill")
                        .frame(width: 30, height: 30)
                        .foregroundStyle(videoManager.showDashCam ? Color.appBlue : Color.appDarkGray)
                        .contentTransition(.symbolEffect(.replace))
                }
                .frame(width: 50, height: 50)
                .background(colorScheme == .dark ? Color.black : Color.appBackground)
                .clipShape(.circle)
                .overlay(
                    Circle().stroke(
                        colorScheme == .dark ? Color.tertiarySystemBackground : Color.white,
                        lineWidth: 1
                    )
                )

                LocateMeButton(viewModel: viewModel, viewport: $viewport)
                
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom, 32)
    }
}
