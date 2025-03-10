//
//  WeelTabView.swift
//  Weel
//
//  Created by Kibret Woldemichael on 3/6/25.
//

import SwiftUI

struct WeelTabView: View {

    var body: some View {
        TabView {
            NavigationHomeView()
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
