//
//  MusicDetailsIntent.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import Foundation
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

@MainActor
class MusicDetailsIntent: ObservableObject {
    @Published private(set) var state: MusicDetailsState
    private var audioPlayer: AVAudioPlayer?
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    private let dbManager = DBManager.shared
    private let fileManager = FAFileManager.shared
    private let httpClient = HttpClient()
    
    init(songInfo: SongInfo) {
        self.state = MusicDetailsState(songInfo: songInfo)
        Task {
            await loadImages()
        }
    }
    
    func loadImages() async {
        state.isLoading = true
        
        do {
            async let artistImage = fetchImage(urlString: state.songInfo.artist.effectiveArtistPicture)
            async let albumCoverImage = fetchImage(urlString: state.songInfo.album.effectiveSongCover)
            
            let (artist, album) = try await (artistImage, albumCoverImage)
            self.state.artistImage = artist
            self.state.albumCoverImage = album
        } catch {
            self.state.errorMessage = "Failed to load images: \(error.localizedDescription)"
        }
        
        state.isLoading = false
    }
    
    func playPreview() {
        Task {
            await playPreviewAsync()
        }
    }
    
    func playPreviewAsync() async {
        guard let url = URL(string: state.songInfo.preview) else {
            state.errorMessage = "Invalid preview URL"
            return
        }
        
        do {
            let data = try await httpClient.fetchData(from: url)
            self.audioPlayer = try AVAudioPlayer(data: data)
            self.audioPlayer?.prepareToPlay()
            self.audioPlayer?.play()
            self.state.isPlaying = true
        } catch {
            self.state.errorMessage = "Failed to play preview: \(error.localizedDescription)"
        }
    }

    func stopPlaying() {
        audioPlayer?.stop()
        state.isPlaying = false
    }

    func bookmarkTrack(context: NSManagedObjectContext) {
        Task {
            await bookmarkTrackAsync(context: context)
        }
    }

    func bookmarkTrackAsync(context: NSManagedObjectContext) async {
        dbManager.setContext(context)
        state.isBookmarked = true
        await saveTrackToLocalStorage(context: context)
    }

    private func saveTrackToLocalStorage(context: NSManagedObjectContext) async {
        guard let url = URL(string: state.songInfo.preview) else {
            state.errorMessage = "Invalid URL"
            return
        }
        
        do {
            let data = try await httpClient.fetchData(from: url)
            guard let tracksDirectory = fileManager.getDirectory(for: "Tracks") else { return }
            let fileName = state.songInfo.title.replacingOccurrences(of: " ", with: "_") + ".mp3"
            let destinationURL = tracksDirectory.appendingPathComponent(fileName)
            
            try data.write(to: destinationURL)
            dbManager.context = context
            dbManager.addMusicData(
                songTitle: state.songInfo.title,
                artistName: state.songInfo.artist.name,
                artistPhoto: state.songInfo.artist.artistPictureSmall,
                albumCover: state.songInfo.album.songCoverSmall
            )
        } catch {
            state.errorMessage = "Failed to save track: \(error.localizedDescription)"
        }
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
                            self.state.errorMessage = "Failed to start recording: \(error.localizedDescription)"
                        }
                    }
                } else {
                    self.state.errorMessage = "Recording permission not granted"
                }
            }
        } catch {
            self.state.errorMessage = "Failed to set up recording session: \(error.localizedDescription)"
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
            state.errorMessage = "Failed to save recording: \(error.localizedDescription)"
        }
    }

    func checkIfBookmarked(context: NSManagedObjectContext) {
        dbManager.setContext(context)
        let allBookmarkedMusic = dbManager.fetchMusicData()
        state.isBookmarked = allBookmarkedMusic.contains { $0.songTitle == state.songInfo.title }
    }
    
    private func fetchImage(urlString: String) async throws -> UIImage? {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        let data = try await httpClient.fetchData(from: url)
        return UIImage(data: data)
    }
}
