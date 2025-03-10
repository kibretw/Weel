//
//  SuggestionView.swift
//  Weel
//
//  Created by Kibret Woldemichael on 3/7/25.
//

import SwiftUI

struct SuggestionView: View {
    var suggestion: MapboxWrapper
    
    var body: some View {
        HStack {
            VStack {
                if let distance = suggestion.distance.formatDistance() {
                    Text(distance)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(suggestion.name ?? "No name")
                    .font(.body)
                    .fontWeight(.bold)
                    .lineLimit(1)
                Text(suggestion.description ?? "No description")
                    .font(.caption)
//                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .clipShape(.rect(cornerRadius: 8))
        .frame(minHeight: 0, maxHeight: .infinity)
    }
}

#Preview {
    SuggestionView(suggestion: MapboxWrapper(id: "test", name: "Test", description: "Testing 123", coordinate: nil, distance: nil, estimatedTime: nil))
}
