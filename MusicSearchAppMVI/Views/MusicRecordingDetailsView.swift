//
//  MusicRecordingDetailsView.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import SwiftUI

struct MusicRecordingDetailsView: View {
    @StateObject var intent: MusicRecordingDetailsIntent

    var body: some View {
        VStack {
            Text(intent.state.recording.title ?? "Untitled")
                .font(.title)
                .padding()
            
            Text("Recorded on \(intent.state.recording.date ?? Date(), formatter: itemFormatter)")
                .font(.subheadline)
                .padding()
            
            Button(action: {
                if intent.state.isPlaying {
                    intent.stopPlaying()
                } else {
                    intent.playRecording()
                }
            }) {
                Text(intent.state.isPlaying ? "Stop" : "Play Recording")
                    .padding()
                    .background(intent.state.isPlaying ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .padding()
    }
}
