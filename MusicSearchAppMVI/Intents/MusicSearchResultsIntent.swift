//
//  MusicSearchResultsIntent.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import Combine
import SwiftUI

//@MainActor
class MusicSearchResultsIntent: ObservableObject {
    @Published private(set) var state: MusicSearchState

    init(searchQuery: String) {
        self.state = MusicSearchState(searchQuery: searchQuery)
        fetchSearchResults()
    }
    
    func fetchSearchResults() {
        state.isLoading = true
        state.errorMessage = nil
        
        Task {
            do {
                let request = MusicSearchRequest(query: state.searchQuery)
                let results: MusicRequestInfo = try await HttpClient().fetchData(from: request)
                self.state.searchResults = results.data
                self.state.isLoading = false
            } catch {
                self.state.errorMessage = error.localizedDescription
                self.state.isLoading = false
            }
        }
    }
}
