//
//  MusicBookmarkedIntent.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import Foundation
import Combine
import CoreData
import SwiftUI

struct MusicBookmarkedState {
    var bookmarkedMusic: [Music] = []
    var errorMessage: String?
}

class MusicBookmarkedIntent: ObservableObject {
    @Published private(set) var state = MusicBookmarkedState()
    private var cancellables = Set<AnyCancellable>()
    private let dbManager = DBManager.shared
    private let fileManager = FAFileManager.shared

    func loadBookmarkedMusic(context: NSManagedObjectContext) {
        dbManager.setContext(context)
        state.bookmarkedMusic = dbManager.fetchMusicData()
    }

    func deleteBookmarkedMusic(context: NSManagedObjectContext, at offsets: IndexSet) {
        for index in offsets {
            let musicToDelete = state.bookmarkedMusic[index]
            
            // 删除local files
            if let songTitle = musicToDelete.songTitle {
                let fileName = songTitle.replacingOccurrences(of: " ", with: "_") + ".mp3"
                if let tracksDirectory = fileManager.getDirectory(for: "Tracks") {
                    let fileURL = tracksDirectory.appendingPathComponent(fileName)
                    print("Attempting to delete file: \(fileURL.path)")
                    if fileManager.deleteFile(at: tracksDirectory, with: fileName) {
                        print("Successfully deleted local file: \(fileURL.path)")
                    } else {
                        print("Failed to delete local file: \(fileURL.path)")
                    }
                }
            }
            
            context.delete(musicToDelete)
        }
        do {
            try context.save()
            loadBookmarkedMusic(context: context)
        } catch {
            state.errorMessage = "Failed to delete music: \(error)"
        }
    }
}
