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

struct MusicBookmarkedDetailsState {
    var artistImage: UIImage?
    var albumCoverImage: UIImage?
    var isPlaying: Bool = false
    let songTitle: String
    let artistName: String
    let artistPhoto: String
    let albumCover: String
}

class MusicBookmarkedDetailsIntent: ObservableObject {
    @Published private(set) var state: MusicBookmarkedDetailsState
    private var cancellables = Set<AnyCancellable>()
    private var audioPlayer: AVAudioPlayer?
    private let fileManager = FAFileManager.shared
    
    init(songTitle: String, artistName: String, artistPhoto: String, albumCover: String) {
        self.state = MusicBookmarkedDetailsState(songTitle: songTitle, artistName: artistName, artistPhoto: artistPhoto, albumCover: albumCover)
        loadImages()
    }
    
    func loadImages() {
        let artistImagePublisher = fetchImage(urlString: state.artistPhoto)
        let albumCoverPublisher = fetchImage(urlString: state.albumCover)
        
        Publishers.Zip(artistImagePublisher, albumCoverPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to load images: \(error)")
                }
            }, receiveValue: { artistImage, albumCoverImage in
                self.state.artistImage = artistImage
                self.state.albumCoverImage = albumCoverImage
            })
            .store(in: &cancellables)
    }

    func playLocalTrack() {
        guard let tracksDirectory = fileManager.getDirectory(for: "Tracks") else {
            print("Failed to get tracks directory")
            return
        }
        let fileName = state.songTitle.replacingOccurrences(of: " ", with: "_") + ".mp3"
        let trackURL = tracksDirectory.appendingPathComponent(fileName)
        
        do {
            let data = try Data(contentsOf: trackURL)
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            state.isPlaying = true
        } catch {
            print("Failed to play local track: \(error)")
        }
    }

    func stopPlaying() {
        audioPlayer?.stop()
        state.isPlaying = false
    }
    
    private func fetchImage(urlString: String) -> AnyPublisher<UIImage?, Error> {
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        return HttpClient().fetchImagePublisher(from: url)
    }
}
