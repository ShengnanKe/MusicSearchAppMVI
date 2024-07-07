//
//  MusicSearchModel.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/6/24.
//

import SwiftUI

class MusicSearchModel: ObservableObject {
    @Published var searchResults: [SongInfo] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchQuery: String = ""
}
