//
//  MusicBookmarkedModel.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/6/24.
//

import Foundation
import Combine

class MusicBookmarkedModel: ObservableObject {
    @Published var bookmarkedMusic: [Music] = []
    @Published var errorMessage: String?
}
