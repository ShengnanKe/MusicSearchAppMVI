//
//  MusicBookmarkedDetailsIntent.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import Foundation
import Combine
import SwiftUI
import AVFoundation

@MainActor
class MusicBookmarkedDetailsIntent: ObservableObject {
    @Published private var model: MusicBookmarkedDetailsModel
    private var audioPlayer: AVAudioPlayer?
    private let fileManager = FAFileManager.shared

    init(model: MusicBookmarkedDetailsModel) {
        self.model = model
        Task {
            await loadImages()
        }
    }
    
    func loadImages() async {
        model.isLoading = true
        
        do {
            async let artistImage = fetchImage(urlString: model.artistPhoto)
            async let albumCoverImage = fetchImage(urlString: model.albumCover)
            
            let (artist, album) = try await (artistImage, albumCoverImage)
            self.model.artistImage = artist
            self.model.albumCoverImage = album
        } catch {
            self.model.errorMessage = "Failed to load images: \(error.localizedDescription)"
        }
        
        model.isLoading = false
    }
    
    func playLocalTrack() {
        guard let tracksDirectory = fileManager.getDirectory(for: "Tracks") else {
            print("Failed to get tracks directory")
            return
        }
        let fileName = model.songTitle.replacingOccurrences(of: " ", with: "_") + ".mp3"
        let trackURL = tracksDirectory.appendingPathComponent(fileName)
        
        do {
            let data = try Data(contentsOf: trackURL)
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            model.isPlaying = true
        } catch {
            print("Failed to play local track: \(error)")
        }
    }

    func stopPlaying() {
        audioPlayer?.stop()
        model.isPlaying = false
    }
    
    private func fetchImage(urlString: String) async throws -> UIImage? {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        let data = try await HttpClient().fetchData(from: url)
        return UIImage(data: data)
    }
}
