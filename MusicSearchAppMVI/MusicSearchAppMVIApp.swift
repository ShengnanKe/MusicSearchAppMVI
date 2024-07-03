//
//  MusicSearchAppMVIApp.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/3/24.
//

import SwiftUI

@main
struct MusicSearchAppMVIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
