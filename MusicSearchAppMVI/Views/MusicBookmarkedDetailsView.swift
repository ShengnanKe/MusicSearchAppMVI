//
//  MusicBookmarkedDetailsView.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import SwiftUI

struct MusicBookmarkedDetailsView: View {
    @StateObject private var container: MVIContainer<MusicBookmarkedDetailsIntent, MusicBookmarkedDetailsModel>

    init(songTitle: String, artistName: String, artistPhoto: String, albumCover: String) {
        let model = MusicBookmarkedDetailsModel(songTitle: songTitle, artistName: artistName, artistPhoto: artistPhoto, albumCover: albumCover)
        let intent = MusicBookmarkedDetailsIntent(model: model)
        _container = StateObject(wrappedValue: MVIContainer(intent: intent, model: model, modelChangePublisher: model.objectWillChange))
    }

    var body: some View {
        VStack {
            Text(container.model.songTitle)
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
            
            Text(container.model.artistName)
                .font(.headline)
                .padding()
            
            Button(action: {
                if container.model.isPlaying {
                    container.intent.stopPlaying()
                } else {
                    container.intent.playLocalTrack()
                }
            }) {
                Text(container.model.isPlaying ? "Stop" : "Play")
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
