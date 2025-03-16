//
//  WeelTabView.swift
//  Weel
//
//  Created by Kibret Woldemichael on 3/6/25.
//

import SwiftUI

struct WeelTabView: View {
    @EnvironmentObject private var videoManager: VideoManager
    
    var body: some View {
        TabView {
            NavigationHomeView(viewModel: StateObject(wrappedValue: NavigationHomeViewModel(videoManager: videoManager)))
                .tabItem {
                    Image(systemName: "car")
                    
                    Text("Drive")
                }
            
            TripsView()
                .tabItem {
                    Image(systemName: "folder")
                    
                    Text("Trips")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    
                    Text("Settings")
                }
        }
    }
}
