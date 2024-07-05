//
//  MusicRecordingDetailsIntent.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import Foundation
import Combine
import AVFoundation
import SwiftUI

struct MusicRecordingDetailsState {
    var isPlaying: Bool = false
    let recording: MusicRecording
}

class MusicRecordingDetailsIntent: ObservableObject {
    @Published private(set) var state: MusicRecordingDetailsState
    private var audioPlayer: AVAudioPlayer?
    private let fileManager = FAFileManager.shared

    init(recording: MusicRecording) {
        self.state = MusicRecordingDetailsState(recording: recording)
    }

    func playRecording() {
        guard let title = state.recording.title else { return }
        guard let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else { return }
        guard let recordingsDirectory = fileManager.getDirectory(for: "Recordings") else {
            print("Failed to get recordings directory")
            return
        }
        let recordingURL = recordingsDirectory.appendingPathComponent("\(encodedTitle).m4a")

        do {
            let data = try Data(contentsOf: recordingURL)
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            state.isPlaying = true
        } catch {
            print("Failed to play recording: \(error)")
        }
    }

    func stopPlaying() {
        audioPlayer?.stop()
        state.isPlaying = false
    }
}
