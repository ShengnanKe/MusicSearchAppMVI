//
//  MusicBookmarkedView.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import SwiftUI
import CoreData

struct MusicBookmarkedView: View {
    @StateObject private var intent = MusicBookmarkedIntent()
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            List {
                ForEach(intent.state.bookmarkedMusic, id: \.self) { music in
                    NavigationLink(destination: MusicBookmarkedDetailsView(intent: MusicBookmarkedDetailsIntent(
                        songTitle: music.songTitle ?? "Unknown Title",
                        artistName: music.artistName ?? "Unknown Artist",
                        artistPhoto: music.artistPhoto ?? "",
                        albumCover: music.albumCover ?? ""
                    ))) {
                        VStack(alignment: .leading) {
                            Text(music.songTitle ?? "Unknown Title")
                                .font(.headline)
                            Text(music.artistName ?? "Unknown Artist")
                                .font(.subheadline)
                        }
                        .padding()
                    }
                }
                .onDelete { offsets in
                    intent.deleteBookmarkedMusic(context: viewContext, at: offsets)
                }
            }
            .navigationTitle("Saved Music")
            .onAppear {
                intent.loadBookmarkedMusic(context: viewContext)
            }
        }
    }
}
