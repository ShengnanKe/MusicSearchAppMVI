//
//  MVIContainer.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/6/24.
//

import Foundation
import Combine
import SwiftUI

final class MVIContainer<Intent: ObservableObject, Model: ObservableObject>: ObservableObject {
    
    @Published var intent: Intent
    @Published var model: Model
    
    private var cancellable: Set<AnyCancellable> = []
    
    init(intent: Intent, model: Model, modelChangePublisher: ObjectWillChangePublisher) {
        self.intent = intent
        self.model = model
        
        modelChangePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &cancellable)
    }
}
