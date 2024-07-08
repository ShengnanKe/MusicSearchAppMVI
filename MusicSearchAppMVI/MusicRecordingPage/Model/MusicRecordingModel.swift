//
//  MusicRecordingModel.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/6/24.
//

import Foundation
import Combine
import SwiftUI

class MusicRecordingModel: ObservableObject {
    @Published var recordings: [MusicRecording] = []
    @Published var errorMessage: String?
}
