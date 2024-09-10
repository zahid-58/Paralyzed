//
//  AudioData.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 10.09.24.
//

import Foundation
import RealmSwift

class AudioData: Object, Identifiable {
    
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var predicted: String
    @Persisted var timestamp: Date
    @Persisted var scanid: UUID?
    @Persisted var detected: Bool
    
    override class func primaryKey() -> String? {
        "id"
    }
}
