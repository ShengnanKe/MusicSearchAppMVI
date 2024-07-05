//
//  MusicBookmarkedDetailsView.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import SwiftUI

struct MusicBookmarkedDetailsView: View {
    @StateObject var intent: MusicBookmarkedDetailsIntent
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        ScrollView {
            VStack {
                Text(intent.state.songTitle)
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
                
                Text(intent.state.artistName)
                    .font(.headline)
                    .padding()
                
                Button(action: {
                    if intent.state.isPlaying {
                        intent.stopPlaying()
                    } else {
                        intent.playLocalTrack()
                    }
                }) {
                    Text(intent.state.isPlaying ? "Stop" : "Play")
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
}
