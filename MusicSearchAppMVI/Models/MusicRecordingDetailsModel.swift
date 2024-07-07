//
//  MusicRecordingDetailsModel.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/6/24.
//

import Foundation
import Combine
import SwiftUI

class MusicRecordingDetailsModel: ObservableObject {
    @Published var isPlaying: Bool = false
    var recording: MusicRecording

    init(recording: MusicRecording) {
        self.recording = recording
    }
}
