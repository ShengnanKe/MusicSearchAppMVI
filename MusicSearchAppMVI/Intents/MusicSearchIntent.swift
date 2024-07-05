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

class MusicSearchIntent: ObservableObject {
    @Published var searchQuery: String = ""
    @Published private(set) var state = MusicSearchState()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                guard let self = self else { return }
                self.state.searchQuery = query
                if !query.isEmpty {
                    self.fetchSearchResults(for: query)
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchSearchResults(for query: String) {
        state.isLoading = true
        state.errorMessage = nil
        
        let request = MusicSearchRequest(query: query)
        
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
