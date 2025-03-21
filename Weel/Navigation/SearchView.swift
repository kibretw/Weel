//
//  SearchView.swift
//  Weel
//
//  Created by Kibret Woldemichael on 3/8/25.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.colorScheme) var colorScheme

    @ObservedObject var viewModel: NavigationHomeViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ZStack(alignment: .trailing) {
                    TextField("Search", text: $viewModel.searchText)
                        .padding()
                        .foregroundStyle(Color.primary)
                        .background(colorScheme == .dark ? Color.black : Color.white)
                        .clipShape(UnevenRoundedRectangle(
                            topLeadingRadius: 8,
                            bottomLeadingRadius: !viewModel.searchText.isEmpty ? 0 : 8,
                            bottomTrailingRadius: !viewModel.searchText.isEmpty ? 0 : 8,
                            topTrailingRadius: 8))
                }
            }
            .padding(.top, 32)
            
            if !viewModel.searchText.isEmpty {
                Divider()
                    .frame(height: 0.5)
                    .foregroundStyle(Color.secondary)
                    .padding(.top, -0.5)
                
                VStack {
                    if viewModel.isSearching {
                        ProgressView()
                    } else if !viewModel.suggestions.isEmpty {
                        List {
                            ForEach(Array(viewModel.getDisplayableSuggestions().enumerated()), id: \.element) { index, suggestion in
                                Button {
                                    viewModel.suggestionSelected(index)
                                } label: {
                                    SuggestionView(suggestion: suggestion)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(minHeight: 50)
                .background(colorScheme == .dark ? Color.black : Color.white)
                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 8, bottomTrailingRadius: 8))
                .transition(.move(edge: .top))
            }

        }
    }
}

#Preview {
    SearchView(viewModel: NavigationHomeViewModel())
}
