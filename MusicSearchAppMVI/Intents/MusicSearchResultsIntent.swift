//
//  MusicSearchResultsIntent.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class MusicSearchResultsIntent: ObservableObject {
    @Published private(set) var model: MusicSearchResultsModel
    
    init(model: MusicSearchResultsModel) {
        self.model = model
        fetchSearchResults()
    }
    
    func fetchSearchResults() {
        model.isLoading = true
        model.errorMessage = nil
        
        Task {
            do {
                let request = MusicSearchRequest(query: model.searchQuery)
                let results: MusicRequestInfo = try await HttpClient().fetchData(from: request)
                self.model.searchResults = results.data
                self.model.isLoading = false
            } catch {
                self.model.errorMessage = error.localizedDescription
                self.model.isLoading = false
            }
        }
    }
}
