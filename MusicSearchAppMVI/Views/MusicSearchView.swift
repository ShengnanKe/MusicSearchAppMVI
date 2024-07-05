//
//  MusicSearchView.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import SwiftUI

struct MusicSearchView: View {
    @StateObject private var intent = MusicSearchIntent()
    
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink(
                    destination: MusicSearchResultsView(intent: intent),
                    isActive: .constant(!intent.state.searchQuery.isEmpty)
                ) {
                    EmptyView()
                }
            }
            .padding()
            .navigationTitle("Music Search Page")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $intent.searchQuery, prompt: "Search for music ...")
        }
    }
}
