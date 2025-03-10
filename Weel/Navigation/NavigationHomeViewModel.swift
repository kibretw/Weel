//
//  NavigationHomeViewModel.swift
//  Weel
//
//  Created by Kibret Woldemichael on 3/6/25.
//

import Combine
import Foundation
import MapboxCommon
import MapboxSearch
import MapboxDirections
import MapboxNavigationCore
import MapboxNavigationUIKit
import UIKit

@MainActor
class NavigationHomeViewModel: ObservableObject {
    lazy var locationManager = CLLocationManager()
    
    private lazy var placeAutocomplete = PlaceAutocomplete()
    
    private lazy var directions = Directions()
    
    private var videoManager = VideoManager()
    
    @Published var searchText: String = ""
    
    @Published var debouncedSearchText: String = ""
    
    @Published var isSearching: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var suggestions: [PlaceAutocomplete.Suggestion] = []
    
    @Published var selectedPlace: MapboxWrapper? = nil {
        didSet {
            routes.removeAll()
            if selectedPlace != nil {
                fetchDirections()
            }
        }
    }
    
    @Published var isFetchingDetails: Bool = false
    
    @Published var isFetchingRoutes: Bool = false
    
    var routes: [MapboxDirections.Route] = [] {
        didSet {
            displayableRoutes = getDisplayableRoutes()
        }
    }
    
    var waypoints: [MapboxDirections.Waypoint] = []
    
    @Published var displayableRoutes: [MapboxRoute] = []
    
    @Published var selectedRouteIndex: Int?
    
    @Published var showRoutes: Bool = false
    
    init() {
        
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.debouncedSearchText = text
                Task { await self?.performSearch(for: text) }
            }
            .store(in: &cancellables)
    }
    
    func getDisplayableSuggestions() -> [MapboxWrapper] {
        suggestions.map({ suggestion in
            return MapboxWrapper(
                id: suggestion.mapboxId ?? UUID().uuidString,
                name: suggestion.name,
                description: suggestion.description,
                coordinate: nil,
                distance: suggestion.distance,
                estimatedTime: suggestion.estimatedTime)
        })
    }
    
    func getDisplayableRoutes() -> [MapboxRoute] {
        routes.map { route in
            let coordinates = route.shape?.coordinates.map { Coordinate(latitude: $0.latitude, longitude: $0.longitude) } ?? []
            return MapboxRoute(id: UUID().uuidString, coordinates: coordinates, distance: route.distance, expectedTravelTime: route.expectedTravelTime)
        }
    }
    
    private func performSearch(for query: String) async {
        guard !query.isEmpty else {
            return
        }
        
        isSearching = true
        
        placeAutocomplete.suggestions(for: query, filterBy: .init(navigationProfile: .driving)) { [weak self] result in
            switch result {
            case .success(let fetchedSuggestions):
                print(fetchedSuggestions)
                self?.suggestions = fetchedSuggestions
                self?.isSearching = false
            case .failure(let error):
                print(error.localizedDescription)
                self?.isSearching = false
                
            }
        }
    }
    
    func suggestionSelected(_ index: Int) {
        isFetchingDetails = true
        placeAutocomplete.select(suggestion: suggestions[index]) { [weak self] placeResult in
            switch placeResult {
            case .success(let place):
                print(place)
                guard let latitude = place.coordinate?.latitude, let longitude = place.coordinate?.longitude else {
                    return
                }
                self?.selectedPlace = MapboxWrapper(id: place.mapboxId ?? UUID().uuidString, name: place.name, description: place.description, coordinate: Coordinate(latitude: latitude, longitude: longitude), distance: place.distance, estimatedTime: place.estimatedTime)
                self?.isFetchingDetails = false
            case .failure(let error):
                print("Error retrieving place details: \(error.localizedDescription)")
                self?.isFetchingDetails = false
            }
        }
    }
    
    func fetchDirections() {
        isFetchingRoutes = true
        guard let origin = locationManager.location?.coordinate, let destination = selectedPlace?.coordinate?.getCoordinate() else {
            isFetchingRoutes = false
            return
        }
        let waypoints = [
            Waypoint(coordinate: LocationCoordinate2D(latitude: origin.latitude, longitude: origin.longitude), name: "Start"),
            Waypoint(coordinate: LocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude), name: "End")
        ]
        
        let options = RouteOptions(waypoints: waypoints, profileIdentifier: .automobile)
        options.includesSteps = true // Ensure turn-by-turn steps are included
        options.includesAlternativeRoutes = true
        
        directions.calculate(options) { result in
            switch result {
            case .success(let response):
                print(response)
                DispatchQueue.main.async {
                    self.waypoints = response.waypoints ?? []
                    self.routes = response.routes?
                        .filter { $0.shape?.coordinates != nil } ?? []
                    self.selectedRouteIndex = 0
                    self.isFetchingRoutes = false
                }
            case .failure(let error):
                print("Error fetching directions: \(error)")
                DispatchQueue.main.async {
                    self.isFetchingRoutes = false
                }
            }
        }
    }
    
    func startNavigation(_ route: MapboxRoute) {
        calculateRoutes(waypoints: waypoints) { nvc in
            DispatchQueue.main.async {
                self.presentViewController(nvc: nvc)
            }
            self.videoManager.startRecording()
        }
        
    }
    
    func presentViewController(nvc: NavigationViewController) {
        // Call a helper function to present the view controller
        if let topViewController = getTopViewController() {
            topViewController.present(nvc, animated: true, completion: nil)
        }
    }
    
    // Helper function to get the topmost view controller
    private func getTopViewController() -> UIViewController? {
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            return getTopViewController(from: window.rootViewController)
        }
        return nil
    }
    
    private func getTopViewController(from rootViewController: UIViewController?) -> UIViewController? {
        if let navigationController = rootViewController as? UINavigationController {
            return getTopViewController(from: navigationController.visibleViewController)
        }
        
        if let tabBarController = rootViewController as? UITabBarController {
            return getTopViewController(from: tabBarController.selectedViewController)
        }
        
        if let presentedViewController = rootViewController?.presentedViewController {
            return getTopViewController(from: presentedViewController)
        }
        
        return rootViewController
    }
    
    @MainActor private func calculateRoutes(waypoints: [Waypoint], completion: @escaping (NavigationViewController) -> Void) {
        
        // create a new navigation provider using simulated device location
        let mapboxNavigationProvider = MapboxNavigationProvider(
            coreConfig: .init(
                locationSource: .live // replace with .live to use the device's location
            )
        )
        
        let mapboxNavigation = mapboxNavigationProvider.mapboxNavigation
        
        let options = NavigationRouteOptions(waypoints: waypoints)
        
        // create the navigation request
        let request = mapboxNavigation.routingProvider().calculateRoutes(options: options)
        
        Task {
            switch await request.result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let navigationRoutes):
                
                // set up options for NavigationViewController
                let navigationOptions = NavigationOptions(
                    mapboxNavigation: mapboxNavigation,
                    voiceController: mapboxNavigationProvider.routeVoiceController,
                    eventsManager: mapboxNavigationProvider.eventsManager()
                )
                
                // create the NavigationViewController, combining the returned routes and the options defined above
                let navigationViewController = NavigationViewController(
                    navigationRoutes: navigationRoutes,
                    navigationOptions: navigationOptions
                )
                navigationViewController.delegate = self
                
                // set additional options on the NavigationViewController
                navigationViewController.modalPresentationStyle = .fullScreen
                
                // Render part of the route that has been traversed with full transparency, to give the illusion of a disappearing route.
                navigationViewController.routeLineTracksTraversal = true
                
                // Return the navigation view controller in the completion handler
                completion(navigationViewController)
            }
        }
    }
}

    // MARK: - NavigationViewControllerDelegate
extension NavigationHomeViewModel: NavigationViewControllerDelegate {
    
    func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
        navigationViewController.dismiss(animated: true) {
            self.videoManager.stopRecording()
            self.searchText = ""
            self.showRoutes = false
            self.suggestions.removeAll()
            self.waypoints.removeAll()
        }
    }
}

