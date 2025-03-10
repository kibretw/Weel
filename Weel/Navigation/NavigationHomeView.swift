//
//  NavigationHomeView.swift
//  Weel
//
//  Created by Kibret Woldemichael on 3/6/25.
//

import SwiftUI
import MapboxMaps

struct NavigationHomeView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var viewModel = NavigationHomeViewModel()

    @State var viewport: Viewport = .followPuck(zoom: 18, bearing: .constant(0))
    
    @State var showRoutes: Bool = false

    @State var showNavigation: Bool = false

    init() {
      UITextField.appearance().clearButtonMode = .whileEditing
    }

    var body: some View {
        ZStack {
            Map(viewport: $viewport) {
                Puck2D(bearing: .heading)
                
                ForEvery(Array(viewModel.displayableRoutes.enumerated()), id: \.element) { (index, route) in
                    if let selectedRouteIndex = viewModel.selectedRouteIndex {
                        PolylineAnnotationGroup {
                            PolylineAnnotation(lineCoordinates: route.coordinates.compactMap {
                                return CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
                            )
                            .lineColor(viewModel.displayableRoutes[selectedRouteIndex].id == route.id ? .blue : .lightGray)
                            .lineBorderColor(viewModel.displayableRoutes[selectedRouteIndex].id == route.id ? .cyan : .gray)
                            .lineWidth(viewModel.displayableRoutes[selectedRouteIndex].id == route.id ? 10 : 4)
                            .lineBorderWidth(viewModel.displayableRoutes[selectedRouteIndex].id == route.id ? 2 : 1)
                            .onTapGesture {
                                viewModel.selectedRouteIndex = index
                            }
                        }
                    }
                }
            }
            .mapStyle(.standard)
            .ignoresSafeArea(.all, edges: .top)
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    LocateMeButton(viewModel: viewModel, viewport: $viewport)
                }
            }
            .padding(.vertical, 32)
            .padding(.horizontal)
            
            VStack {
                if viewModel.selectedPlace == nil && !showRoutes {
                    SearchView(viewModel: viewModel)
                        .padding(.horizontal)
                }
                Spacer()
            }
        }
        .onChange(of: viewModel.selectedPlace) { old, new in
            if let new = new, let coordinate = new.coordinate?.getCoordinate() {
                viewport = .camera(center: coordinate, zoom: 16)
                showRoutes = true
            }
        }
        .onChange(of: viewModel.selectedRouteIndex) { old, new in
            if let new {
                viewport = .overview(
                    geometry: LineString(viewModel.displayableRoutes[new].coordinates.map({ CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)})),
                    geometryPadding: .init(top: 40, leading: 40, bottom: 40, trailing: 40))
            }
        }
        .sheet(isPresented: $showRoutes, onDismiss: {
            viewModel.selectedPlace = nil
        }, content: {
            if let selectedPlace = viewModel.selectedPlace {
                SelectedPlaceView(viewModel: viewModel, place: selectedPlace, showNavigation: $showNavigation)
            }
        })
    }
}

#Preview {
    NavigationHomeView()
}
