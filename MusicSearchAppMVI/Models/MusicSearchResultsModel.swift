//
//  MusicSearchResultsModel.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/6/24.
//

import Foundation
import Combine

class MusicSearchResultsModel: ObservableObject {
    @Published var searchResults: [SongInfo] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    var searchQuery: String
    
    init(searchQuery: String) {
        self.searchQuery = searchQuery
    }
}
