//
//  MusicRecordingView.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import SwiftUI
import CoreData

struct MusicRecordingView: View {
    @StateObject private var container: MVIContainer<MusicRecordingIntent, MusicRecordingModel>
    @Environment(\.managedObjectContext) private var viewContext

    init() {
        let model = MusicRecordingModel()
        let intent = MusicRecordingIntent(model: model)
        _container = StateObject(wrappedValue: MVIContainer(intent: intent, model: model, modelChangePublisher: model.objectWillChange))
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(container.model.recordings, id: \.self) { recording in
                    NavigationLink(destination: MusicRecordingDetailsView(recording: recording)) {
                        VStack(alignment: .leading) {
                            Text(recording.title ?? "Untitled")
                                .font(.headline)
                            Text("Recorded on \(recording.date ?? Date(), formatter: itemFormatter)")
                                .font(.subheadline)
                        }
                        .padding()
                    }
                }
                .onDelete { offsets in
                    container.intent.deleteRecording(context: viewContext, at: offsets)
                }
            }
            .navigationTitle("Music Recordings")
            .onAppear {
                container.intent.loadRecordings(context: viewContext)
            }
        }
    }
}
