//
//  MusicDetailsIntent.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import Combine
import SwiftUI
import AVFoundation
import CoreData

struct MusicDetailsState {
    var artistImage: UIImage?
    var albumCoverImage: UIImage?
    var isLoading: Bool = false
    var errorMessage: String?
    var isBookmarked: Bool = false
    var isPlaying: Bool = false
    var isRecording: Bool = false
    var showRecordingSheet: Bool = false
    let songInfo: SongInfo
}

class MusicDetailsIntent: ObservableObject {
    @Published private(set) var state: MusicDetailsState
    private var cancellables = Set<AnyCancellable>()
    private var audioPlayer: AVAudioPlayer?
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    private let dbManager = DBManager.shared
    private let fileManager = FAFileManager.shared
    private let httpClient = HttpClient()
    
    init(songInfo: SongInfo) {
        self.state = MusicDetailsState(songInfo: songInfo)
        loadImages()
    }
    
    func loadImages() {
        state.isLoading = true
        
        let artistImagePublisher = fetchImage(urlString: state.songInfo.artist.effectiveArtistPicture)
        let albumCoverPublisher = fetchImage(urlString: state.songInfo.album.effectiveSongCover)
        
        Publishers.Zip(artistImagePublisher, albumCoverPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.state.errorMessage = "Failed to load images: \(error)"
                }
                self.state.isLoading = false
            }, receiveValue: { artistImage, albumCoverImage in
                self.state.artistImage = artistImage
                self.state.albumCoverImage = albumCoverImage
            })
            .store(in: &cancellables)
    }
    
    func playPreview() {
        guard let url = URL(string: state.songInfo.preview) else {
            state.errorMessage = "Invalid preview URL"
            return
        }
        
        httpClient.fetchDataPublisher(from: url)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.state.errorMessage = "Failed to play preview: \(error)"
                }
            }, receiveValue: { data in
                self.audioPlayer = try? AVAudioPlayer(data: data)
                self.audioPlayer?.prepareToPlay()
                self.audioPlayer?.play()
                self.state.isPlaying = true
            })
            .store(in: &cancellables)
    }

    func stopPlaying() {
        audioPlayer?.stop()
        state.isPlaying = false
    }

    func bookmarkTrack(context: NSManagedObjectContext) {
        dbManager.setContext(context)
        state.isBookmarked = true
        saveTrackToLocalStorage(context: context)
    }

    private func saveTrackToLocalStorage(context: NSManagedObjectContext) {
        guard let url = URL(string: state.songInfo.preview) else {
            state.errorMessage = "Invalid URL"
            return
        }
        
        httpClient.fetchDataPublisher(from: url)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.state.errorMessage = "Failed to save track: \(error)"
                }
            }, receiveValue: { data in
                guard let tracksDirectory = self.fileManager.getDirectory(for: "Tracks") else { return }
                let fileName = self.state.songInfo.title.replacingOccurrences(of: " ", with: "_") + ".mp3"
                let destinationURL = tracksDirectory.appendingPathComponent(fileName)
                do {
                    try data.write(to: destinationURL)
                    self.dbManager.context = context
                    self.dbManager.addMusicData(
                        songTitle: self.state.songInfo.title,
                        artistName: self.state.songInfo.artist.name,
                        artistPhoto: self.state.songInfo.artist.artistPictureSmall,
                        albumCover: self.state.songInfo.album.songCoverSmall
                    )
                } catch {
                    self.state.errorMessage = "Failed to save track: \(error)"
                }
            })
            .store(in: &cancellables)
    }

    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            audioSession.requestRecordPermission { granted in
                if granted {
                    DispatchQueue.main.async {
                        let recordingName = UUID().uuidString + ".m4a"
                        guard let recordingDirectory = self.fileManager.getDirectory(for: "Recordings") else { return }
                        self.recordingURL = recordingDirectory.appendingPathComponent(recordingName)
                        
                        let settings = [
                            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey: 12000,
                            AVNumberOfChannelsKey: 1,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                        ]
                        
                        do {
                            self.audioRecorder = try AVAudioRecorder(url: self.recordingURL!, settings: settings)
                            self.audioRecorder?.record()
                            self.state.isRecording = true
                        } catch {
                            self.state.errorMessage = "Failed to start recording: \(error)"
                        }
                    }
                } else {
                    self.state.errorMessage = "Recording permission not granted"
                }
            }
        } catch {
            self.state.errorMessage = "Failed to set up recording session: \(error)"
        }
    }

    func stopRecording(title: String, context: NSManagedObjectContext) {
        audioRecorder?.stop()
        state.isRecording = false
        
        guard let recordingURL = recordingURL else { return }
        
        do {
            let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? title
            let destinationURL = recordingURL.deletingLastPathComponent().appendingPathComponent("\(encodedTitle).m4a")
            try FileManager.default.moveItem(at: recordingURL, to: destinationURL)
            dbManager.setContext(context)
            dbManager.addRecording(title: title, date: Date())
        } catch {
            state.errorMessage = "Failed to save recording: \(error)"
        }
    }

    func checkIfBookmarked(context: NSManagedObjectContext) {
        dbManager.setContext(context)
        let allBookmarkedMusic = dbManager.fetchMusicData()
        state.isBookmarked = allBookmarkedMusic.contains { $0.songTitle == state.songInfo.title }
    }
    
    private func fetchImage(urlString: String) -> AnyPublisher<UIImage?, Error> {
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        return httpClient.fetchImagePublisher(from: url)
    }
}
