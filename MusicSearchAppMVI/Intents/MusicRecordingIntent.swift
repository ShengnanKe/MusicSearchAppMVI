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

@MainActor
class MusicRecordingIntent: ObservableObject {
    @Published private(set) var model: MusicRecordingModel
    private var cancellables = Set<AnyCancellable>()
    private let dbManager = DBManager.shared
    private let fileManager = FAFileManager.shared

    init(model: MusicRecordingModel) {
        self.model = model
    }

    func loadRecordings(context: NSManagedObjectContext) {
        dbManager.setContext(context)
        model.recordings = dbManager.fetchRecordingData()
    }

    func deleteRecording(context: NSManagedObjectContext, at offsets: IndexSet) {
        for index in offsets {
            let recordingToDelete = model.recordings[index]
            
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
        
        saveContext(context)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.model.errorMessage = "Failed to delete recording: \(error.localizedDescription)"
                case .finished:
                    break
                }
            }, receiveValue: {
                self.loadRecordings(context: context)
            })
            .store(in: &cancellables)
    }
    
    private func saveContext(_ context: NSManagedObjectContext) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            do {
                try context.save()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
