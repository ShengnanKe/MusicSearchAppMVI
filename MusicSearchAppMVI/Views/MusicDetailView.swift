//
//  MusicDetailView.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import SwiftUI

struct MusicDetailView: View {
    @StateObject var intent: MusicDetailsIntent
    @Environment(\.managedObjectContext) private var viewContext
    @State private var recordingTitle: String = ""
    @State private var showRecordingSheet = false

    var body: some View {
        ScrollView {
            VStack {
                Text(intent.state.songInfo.title)
                    .font(.title)
                    .padding()
                
                if let artistImage = intent.state.artistImage {
                    Image(uiImage: artistImage)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .padding()
                }
                
                if let albumCoverImage = intent.state.albumCoverImage {
                    Image(uiImage: albumCoverImage)
                        .resizable()
                        .frame(width: 200, height: 200)
                        .padding()
                }
                
                Text(intent.state.songInfo.artist.name)
                    .font(.headline)
                    .padding()
                
                Button(action: {
                    if intent.state.isPlaying {
                        intent.stopPlaying()
                    } else {
                        intent.playPreview()
                    }
                }) {
                    Text(intent.state.isPlaying ? "Stop" : "Play Preview")
                        .padding()
                        .background(intent.state.isPlaying ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
                Button(action: {
                    intent.bookmarkTrack(context: viewContext)
                }) {
                    Image(systemName: intent.state.isBookmarked ? "bookmark.fill" : "bookmark")
                }
                .padding()

                Button(action: {
                    if intent.state.isRecording {
                        showRecordingSheet = true
                    } else {
                        intent.startRecording()
                    }
                }) {
                    Text(intent.state.isRecording ? "Stop Recording" : "Start Recording")
                        .padding()
                        .background(intent.state.isRecording ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .sheet(isPresented: $showRecordingSheet) {
                    RecordingTitleSheet(recordingTitle: $recordingTitle, onSave: {
                        intent.stopRecording(title: recordingTitle, context: viewContext)
                        showRecordingSheet = false
                    }, onCancel: {
                        intent.stopRecording(title: "Untitled", context: viewContext)
                        showRecordingSheet = false
                    })
                }
            }
            .padding()
            .onAppear {
                intent.checkIfBookmarked(context: viewContext)
            }
        }
    }
}
