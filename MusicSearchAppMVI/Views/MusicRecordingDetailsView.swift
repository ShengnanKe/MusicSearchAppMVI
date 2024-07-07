//
//  MusicRecordingDetailsView.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import SwiftUI

struct MusicRecordingDetailsView: View {
    @StateObject private var container: MVIContainer<MusicRecordingDetailsIntent, MusicRecordingDetailsModel>

    init(recording: MusicRecording) {
        let model = MusicRecordingDetailsModel(recording: recording)
        let intent = MusicRecordingDetailsIntent(model: model)
        _container = StateObject(wrappedValue: MVIContainer(intent: intent, model: model, modelChangePublisher: model.objectWillChange))
    }

    var body: some View {
        VStack {
            Text(container.model.recording.title ?? "Untitled")
                .font(.title)
                .padding()
            
            Text("Recorded on \(container.model.recording.date ?? Date(), formatter: itemFormatter)")
                .font(.subheadline)
                .padding()
            
            Button(action: {
                if container.model.isPlaying {
                    container.intent.stopPlaying()
                } else {
                    container.intent.playRecording()
                }
            }) {
                Text(container.model.isPlaying ? "Stop" : "Play Recording")
                    .padding()
                    .background(container.model.isPlaying ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .padding()
    }
}
