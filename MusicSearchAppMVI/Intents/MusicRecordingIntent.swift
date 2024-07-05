//
//  MusicRecordingIntent.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import Foundation
import Combine
import CoreData
import SwiftUI

struct MusicRecordingState {
    var recordings: [MusicRecording] = []
    var errorMessage: String?
}

class MusicRecordingIntent: ObservableObject {
    @Published private(set) var state = MusicRecordingState()
    private var cancellables = Set<AnyCancellable>()
    private let dbManager = DBManager.shared
    private let fileManager = FAFileManager.shared

    func loadRecordings(context: NSManagedObjectContext) {
        dbManager.setContext(context)
        state.recordings = dbManager.fetchRecordingData()
    }

    func deleteRecording(context: NSManagedObjectContext, at offsets: IndexSet) {
        for index in offsets {
            let recordingToDelete = state.recordings[index]
            
            // 删除local file
            if let title = recordingToDelete.title {
                let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? title
                let fileName = encodedTitle + ".m4a"
                if let recordingsDirectory = fileManager.getDirectory(for: "Recordings") {
                    let fileURL = recordingsDirectory.appendingPathComponent(fileName)
                    print("Attempting to delete file: \(fileURL.path)")
                    if fileManager.isExist(file: fileURL) {
                        print("File exists: \(fileURL.path)")
                        if fileManager.isWritable(file: fileURL) {
                            print("File is writable: \(fileURL.path)")
                            if fileManager.deleteFile(at: recordingsDirectory, with: fileName) {
                                print("Successfully deleted local file: \(fileURL.path)")
                            } else {
                                print("Failed to delete local file: \(fileURL.path)")
                            }
                        } else {
                            print("File is not writable: \(fileURL.path)")
                        }
                    } else {
                        print("File does not exist: \(fileURL.path)")
                    }
                }
            }
            
            context.delete(recordingToDelete)
        }
        do {
            try context.save()
            loadRecordings(context: context)
        } catch {
            state.errorMessage = "Failed to delete recording: \(error)"
        }
    }
}
