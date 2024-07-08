//
//  MusicDetailsModel.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/6/24.
//

import SwiftUI

class MusicDetailsModel: ObservableObject {
    @Published var artistImage: UIImage?
    @Published var albumCoverImage: UIImage?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isBookmarked: Bool = false
    @Published var isPlaying: Bool = false
    @Published var isRecording: Bool = false
    @Published var showRecordingSheet: Bool = false
    let songInfo: SongInfo
    
    init(songInfo: SongInfo) {
        self.songInfo = songInfo
    }
}
