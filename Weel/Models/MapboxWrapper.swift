//
//  MapboxWrapper.swift
//  Weel
//
//  Created by Kibret Woldemichael on 3/7/25.
//
import Foundation
import CoreLocation

struct MapboxWrapper: Hashable {
    /// Mapbox ID
    let id: String
    
    /// Place's name.
    let name: String?
    
    /// Contains formatted address.
    let description: String?

    /// Geographic point.
    let coordinate: Coordinate?

    /// The straight line distance in meters between the origin and this suggestion.
    let distance: CLLocationDistance?

    /// Estimated time of arrival (in minutes) based on specified `proximity`.
    let estimatedTime: Measurement<UnitDuration>?

    func formatDuration() -> String? {
        guard let estimatedTime else { return nil }
        let totalMinutes = Int(estimatedTime.converted(to: .minutes).value)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 {
            return "\(hours) \(hours == 1 ? "hr" : "hrs") \(minutes) min"
        } else {
            return "\(minutes) min"
        }
    }
}

struct Coordinate: Codable, Hashable {
    let latitude, longitude: Double
    
    func getCoordinate() -> CLLocationCoordinate2D? {
        return CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
}

struct MapboxRoute: Codable, Hashable {
    let id: String
    
    let coordinates: [Coordinate]
    
    let distance: CLLocationDistance?

    let expectedTravelTime: TimeInterval?

}

extension CLLocationDistance? {
    func formatDistance(useMetric: Bool = true) -> String? {
        guard let self else { return nil }
        if useMetric {
            let kilometers = self / 1000
            return String(format: "%.1f km", kilometers)
        } else {
            let miles = self / 1609.34
            return String(format: "%.1f mi", miles)
        }
    }
}

extension TimeInterval {
    func formattedTime() -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .full // "1 hour, 15 minutes"
        formatter.zeroFormattingBehavior = .dropLeading
        
        return formatter.string(from: self)
    }
}
