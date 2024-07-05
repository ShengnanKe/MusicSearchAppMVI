//
//  MusicRecordingView.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import SwiftUI
import CoreData

struct MusicRecordingView: View {
    @StateObject private var intent = MusicRecordingIntent()
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            List {
                ForEach(intent.state.recordings, id: \.self) { recording in
                    NavigationLink(destination: MusicRecordingDetailsView(intent: MusicRecordingDetailsIntent(recording: recording))) {
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
                    intent.deleteRecording(context: viewContext, at: offsets)
                }
            }
            .navigationTitle("Music Recordings")
            .onAppear {
                intent.loadRecordings(context: viewContext)
            }
        }
    }
}
