//
//  SelectedPlaceView.swift
//  Weel
//
//  Created by Kibret Woldemichael on 3/8/25.
//

import MapboxDirections
import MapboxNavigationCore
import MapboxNavigationUIKit
import SwiftUI
import CoreLocation

struct SelectedPlaceView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var viewModel: NavigationHomeViewModel

    var place: MapboxWrapper
    
    @Binding var showNavigation: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading) {
                    Text(place.name ?? place.description ?? "")
                        .foregroundStyle(.primary)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    HStack {
                        if let distance = place.distance.formatDistance() {
                            Image(systemName: "ruler")
                                .foregroundStyle(.secondary)
                            
                            Text(distance)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        
//                        if let duration = place.formatDuration() {
//                            Image(systemName: "clock")
//                                .foregroundStyle(.secondary)
//                            
//                            Text(duration)
//                                .font(.subheadline)
//                                .foregroundStyle(.secondary)
//                                .lineLimit(1)
//                                .minimumScaleFactor(0.7)
//                        }
                    }
                }
                
                Spacer()
                
                Button {
                    dismiss()
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .padding([.top, .horizontal])
            
            Divider()
                .frame(height: 0.5)
                .foregroundStyle(Color.secondary)
            
            List {
                ForEach(viewModel.getDisplayableRoutes(), id: \.self) { route in
                    HStack {
                        VStack(alignment: .leading) {
                            if let time = route.expectedTravelTime?.formattedTime() {
                                Text(time)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                            }
                            
                            HStack {
                                Text("\(Date(timeIntervalSinceNow: route.expectedTravelTime ?? 0).formatted(date: .omitted, time: .shortened)) ETA")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)

                                Text("\u{2022}")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                                
                                Text(route.distance.formatDistance(useMetric: false) ?? "N/A")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            viewModel.startNavigation(route)
                        } label: {
                            Text("Go")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
                }
            }
            .listStyle(.plain)
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .presentationDetents(Set([.height(250)]))
        .interactiveDismissDisabled()
        .presentationBackgroundInteraction(.enabled)
    }
}

//#Preview {
//    Text("Hello World")
//        .sheet(isPresented: .constant(true)) {
//            SelectedPlaceView(viewModel: NavigationHomeViewModel(), place: MapboxWrapper(id: "", name: "Madison Square Park", description: "11 Madison Ave, New York City, New York 10010, United States", coordinate: Coordinate(latitude: 40.742176, longitude: -73.988068), distance: 4019, estimatedTime: .init(value: 16.95, unit: .minutes)), showNavigation: .constant(false))
//        }
//}
