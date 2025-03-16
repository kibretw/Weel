//
//  LocateMeButton.swift
//  Weel
//
//  Created by Kibret Woldemichael on 3/7/25.
//

import SwiftUI
import MapboxMaps

struct LocateMeButton: View {
    @Environment(\.colorScheme) var colorScheme

    @ObservedObject var viewModel: NavigationHomeViewModel

    @Binding var viewport: Viewport
    
    var body: some View {
        Button {
            viewport = .camera(center: viewModel.locationManager.location?.coordinate)
        } label: {
            Image(systemName: imageName)
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
    }

    private var isFocusingUser: Bool {
        return viewport.camera?.center == viewModel.locationManager.location?.coordinate
    }

    private var imageName: String {
        if isFocusingUser {
           return  "location.fill"
        }
        return "location"

    }
}
