//
//  DBManager.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import CoreData
import UIKit

class DBManager {
    static let shared = DBManager()
    var context: NSManagedObjectContext!
    
    private init() {}
    
    func setContext(_ context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getSQLiteFilePath() -> String? {
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let sqlitePath = urls[0].appendingPathComponent("SwiftUIAssignment.sqlite").path
        return sqlitePath
    }
    
    func addMusicData(songTitle: String, artistName: String, artistPhoto: String, albumCover: String) {
        let musicEntity = Music(context: context)
        musicEntity.songTitle = songTitle
        musicEntity.artistName = artistName
        musicEntity.artistPhoto = artistPhoto
        musicEntity.albumCover = albumCover
        saveContext()
    }
    
    func addRecording(title: String, date: Date) {
        let recordingEntity = MusicRecording(context: context)
        recordingEntity.title = title
        recordingEntity.date = date
        saveContext()
    }
    
    func fetchMusicData() -> [Music] {
        guard let context = context else {
            return []
        }
        let request: NSFetchRequest<Music> = Music.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch music data: \(error)")
            return []
        }
    }
    
    func fetchRecordingData() -> [MusicRecording] {
        guard let context = context else {
            return []
        }
        let request: NSFetchRequest<MusicRecording> = MusicRecording.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch recording data: \(error)")
            return []
        }
    }
    
    func deleteMusic(musicEntity: Music) {
        context.delete(musicEntity)
        saveContext()
    }
    
    func deleteRecording(recordingEntity: MusicRecording) {
        context.delete(recordingEntity)
        saveContext()
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func printFilePaths() {
        if let sqlitePath = getSQLiteFilePath() {
            print("SQLite File Path: \(sqlitePath)")
        }
        if let tracksDirectory = FAFileManager.shared.getDirectory(for: "Tracks") {
            print("Tracks Directory: \(tracksDirectory.path)")
        }
        if let recordingsDirectory = FAFileManager.shared.getDirectory(for: "Recordings") {
            print("Recordings Directory: \(recordingsDirectory.path)")
        }
    }
}
