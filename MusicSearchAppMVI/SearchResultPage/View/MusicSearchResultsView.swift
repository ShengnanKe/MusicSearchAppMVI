//
//  MusicSearchResultsView.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import SwiftUI

struct MusicSearchResultsView: View {
    @ObservedObject var container: MVIContainer<MusicSearchIntent, MusicSearchModel>
    
    var body: some View {
        VStack {
            if container.model.isLoading {
                ProgressView()
                    .scaleEffect(2.0, anchor: .center)
                    .padding()
            } else if let errorMessage = container.model.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                        ForEach(container.model.searchResults, id: \.title) { song in
                            NavigationLink(destination: MusicDetailView(songInfo: song)) {
                                VStack {
                                    AsyncImage(url: URL(string: song.album.effectiveSongCover)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(8)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    Text(song.title)
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Search Results")
    }
}
