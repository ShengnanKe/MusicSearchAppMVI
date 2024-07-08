//
//  MusicBookmarkedDetailsModel.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/6/24.
//

import SwiftUI

class MusicBookmarkedDetailsModel: ObservableObject {
    @Published var artistImage: UIImage?
    @Published var albumCoverImage: UIImage?
    @Published var isPlaying: Bool = false
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    let songTitle: String
    let artistName: String
    let artistPhoto: String
    let albumCover: String
    
    init(songTitle: String, artistName: String, artistPhoto: String, albumCover: String) {
        self.songTitle = songTitle
        self.artistName = artistName
        self.artistPhoto = artistPhoto
        self.albumCover = albumCover
    }
}
