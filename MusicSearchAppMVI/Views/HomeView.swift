//
//  HomeView.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            MusicSearchView()
                .tabItem{
                    Image(systemName: "music.note")
                    Text("Music")
                }
            MusicBookmarkedView()
                .tabItem{
                    Image(systemName: "bookmark")
                    Text("Saved Music")
                }
            MusicRecordingView()
                .tabItem{
                    Image(systemName: "record.circle")
                    Text("Music Recordings")
                }
        }
    }
}

//#Preview {
//    HomeView()
//}
