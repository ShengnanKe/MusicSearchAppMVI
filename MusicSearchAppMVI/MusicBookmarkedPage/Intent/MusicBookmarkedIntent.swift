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

@MainActor
class MusicBookmarkedIntent: ObservableObject {
    @Published private var model: MusicBookmarkedModel
    private var cancellables = Set<AnyCancellable>()
    private let dbManager = DBManager.shared
    private let fileManager = FAFileManager.shared

    init(model: MusicBookmarkedModel) {
        self.model = model
    }

    func loadBookmarkedMusic(context: NSManagedObjectContext) {
        dbManager.setContext(context)
        model.bookmarkedMusic = dbManager.fetchMusicData()
    }

    func deleteBookmarkedMusic(context: NSManagedObjectContext, at offsets: IndexSet) {
        for index in offsets {
            let musicToDelete = model.bookmarkedMusic[index]
            
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
            model.errorMessage = "Failed to delete music: \(error)"
        }
    }
}
