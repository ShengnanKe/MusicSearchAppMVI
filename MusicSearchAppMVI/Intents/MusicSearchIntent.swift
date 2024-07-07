//
//  MusicSearchIntent.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class MusicSearchIntent: ObservableObject {
    @Published private(set) var model: MusicSearchModel
    
    init(model: MusicSearchModel) {
        self.model = model
    }
    
    func fetchSearchResults(for query: String) async {
        model.isLoading = true
        model.errorMessage = nil
        
        let request = MusicSearchRequest(query: query)
        
        do {
            let results: MusicRequestInfo = try await HttpClient().fetchData(from: request)
            model.searchResults = results.data
            model.isLoading = false
        } catch {
            model.errorMessage = error.localizedDescription
            model.isLoading = false
        }
    }
}
