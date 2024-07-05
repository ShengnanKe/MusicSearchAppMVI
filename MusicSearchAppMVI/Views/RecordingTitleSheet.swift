//
//  RecordingTitleSheet.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import SwiftUI

struct RecordingTitleSheet: View {
    @Binding var recordingTitle: String
    var onSave: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recording Title")) {
                    TextField("Enter recording title", text: $recordingTitle)
                }
                
                Section {
                    Button(action: onSave) {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: onCancel) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .navigationBarTitle("Save Recording", displayMode: .inline)
        }
    }
}

//
//#Preview {
//    RecordingTitleSheet()
//}
