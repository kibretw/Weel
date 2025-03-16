//
//  WeelApp.swift
//  Weel
//
//  Created by Kibret Woldemichael on 3/6/25.
//

import SwiftUI

@main
struct WeelApp: App {
    @StateObject private var videoManager = VideoManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationHomeView(viewModel: StateObject(wrappedValue: NavigationHomeViewModel(videoManager: videoManager)))
                .tabItem {
                    Image(systemName: "car")
                    
                    Text("Drive")
                }
                .environmentObject(videoManager)
        }
    }
}
