//
//  MusicSearchIntent.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import Combine
import SwiftUI
import Foundation

struct MusicSearchState {
    var searchResults: [SongInfo] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var searchQuery: String = ""
}

@MainActor
class MusicSearchIntent: ObservableObject {
    @Published var searchQuery: String = ""
    @Published private(set) var state = MusicSearchState()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchQuery
            .debounce(for: .milliseconds(1000), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                guard let self = self else { return }
                self.state.searchQuery = query
                if !query.isEmpty {
                    Task {
                        await self.fetchSearchResults(for: query)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchSearchResults(for query: String) async {
        state.isLoading = true
        state.errorMessage = nil
        
        let request = MusicSearchRequest(query: query)
        
        do {
            let results: MusicRequestInfo = try await HttpClient().fetchData(from: request)
            state.searchResults = results.data
            state.isLoading = false
        } catch {
            state.errorMessage = error.localizedDescription
            state.isLoading = false
        }
    }
}
