//
//  MusicBookmarkedView.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import SwiftUI
import CoreData

struct MusicBookmarkedView: View {
    @StateObject private var container: MVIContainer<MusicBookmarkedIntent, MusicBookmarkedModel>
    @Environment(\.managedObjectContext) private var viewContext

    init() {
        let model = MusicBookmarkedModel()
        let intent = MusicBookmarkedIntent(model: model)
        _container = StateObject(wrappedValue: MVIContainer(intent: intent, model: model, modelChangePublisher: model.objectWillChange))
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(container.model.bookmarkedMusic, id: \.self) { music in
                    NavigationLink(destination: MusicBookmarkedDetailsView(
                        songTitle: music.songTitle ?? "Unknown Title",
                        artistName: music.artistName ?? "Unknown Artist",
                        artistPhoto: music.artistPhoto ?? "",
                        albumCover: music.albumCover ?? ""
                    )) {
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
                    container.intent.deleteBookmarkedMusic(context: viewContext, at: offsets)
                }
            }
            .navigationTitle("Saved Music")
            .onAppear {
                container.intent.loadBookmarkedMusic(context: viewContext)
            }
        }
    }
}
