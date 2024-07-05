//
//  MusicSearchResultsIntent.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import Combine
import SwiftUI

class MusicSearchResultsIntent: ObservableObject {
    @Published private(set) var state: MusicSearchState
    private var cancellables = Set<AnyCancellable>()
    
    init(searchQuery: String) {
        self.state = MusicSearchState(searchQuery: searchQuery)
        fetchSearchResults()
    }
    
    func fetchSearchResults() {
        state.isLoading = true
        state.errorMessage = nil
        
        let request = MusicSearchRequest(query: state.searchQuery)
        
        HttpClient().fetchDataPublisher(from: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.state.errorMessage = error.localizedDescription
                    self.state.isLoading = false
                case .finished:
                    break
                }
            }, receiveValue: { (results: MusicRequestInfo) in
                self.state.searchResults = results.data
                self.state.isLoading = false
            })
            .store(in: &cancellables)
    }
}
