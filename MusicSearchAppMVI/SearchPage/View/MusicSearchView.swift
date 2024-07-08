//
//  MusicSearchView.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import SwiftUI

struct MusicSearchView: View {
    @StateObject private var container: MVIContainer<MusicSearchIntent, MusicSearchModel>
    @State private var isSearching = false
    
    init() {
        let model = MusicSearchModel()
        let intent = MusicSearchIntent(model: model)
        _container = StateObject(wrappedValue: MVIContainer(intent: intent, model: model, modelChangePublisher: model.objectWillChange))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Search for music ...", text: $container.model.searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        isSearching = true
                        Task {
                            await container.intent.fetchSearchResults(for: container.model.searchQuery)
                            isSearching = false
                        }
                    }) {
                        Text("Search")
                    }
                }
                .padding()
                
                NavigationLink(
                    destination: MusicSearchResultsView(container: container),
                    isActive: $isSearching
                ) {
                    EmptyView()
                }
            }
            .navigationTitle("Music Search Page")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
