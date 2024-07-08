//
//  MusicDetailView.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import SwiftUI

struct MusicDetailView: View {
    @StateObject private var container: MVIContainer<MusicDetailsIntent, MusicDetailsModel>
    @Environment(\.managedObjectContext) private var viewContext
    @State private var recordingTitle: String = ""
    @State private var showRecordingSheet = false

    init(songInfo: SongInfo) {
        let model = MusicDetailsModel(songInfo: songInfo)
        let intent = MusicDetailsIntent(model: model)
        _container = StateObject(wrappedValue: MVIContainer(intent: intent, model: model, modelChangePublisher: model.objectWillChange))
    }

    var body: some View {
        ScrollView {
            VStack {
                Text(container.model.songInfo.title)
                    .font(.title)
                    .padding()
                
                if let artistImage = container.model.artistImage {
                    Image(uiImage: artistImage)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .padding()
                }
                
                if let albumCoverImage = container.model.albumCoverImage {
                    Image(uiImage: albumCoverImage)
                        .resizable()
                        .frame(width: 200, height: 200)
                        .padding()
                }
                
                Text(container.model.songInfo.artist.name)
                    .font(.headline)
                    .padding()
                
                Button(action: {
                    if container.model.isPlaying {
                        container.intent.stopPlaying()
                    } else {
                        Task {
                            await container.intent.playPreviewAsync()
                        }
                    }
                }) {
                    Text(container.model.isPlaying ? "Stop" : "Play Preview")
                        .padding()
                        .background(container.model.isPlaying ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
                Button(action: {
                    Task {
                        await container.intent.bookmarkTrackAsync(context: viewContext)
                    }
                }) {
                    Image(systemName: container.model.isBookmarked ? "bookmark.fill" : "bookmark")
                }
                .padding()

                Button(action: {
                    if container.model.isRecording {
                        showRecordingSheet = true
                    } else {
                        container.intent.startRecording()
                    }
                }) {
                    Text(container.model.isRecording ? "Stop Recording" : "Start Recording")
                        .padding()
                        .background(container.model.isRecording ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .sheet(isPresented: $showRecordingSheet) {
                    RecordingTitleSheet(recordingTitle: $recordingTitle, onSave: {
                        container.intent.stopRecording(title: recordingTitle, context: viewContext)
                        showRecordingSheet = false
                    }, onCancel: {
                        container.intent.stopRecording(title: "Untitled", context: viewContext)
                        showRecordingSheet = false
                    })
                }
            }
            .padding()
            .onAppear {
                container.intent.checkIfBookmarked(context: viewContext)
            }
        }
    }
}
