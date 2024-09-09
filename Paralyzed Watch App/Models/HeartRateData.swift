//
//  HeartRateData.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 24.08.24.
//

import Foundation
import RealmSwift

class HeartRateData: Object, Identifiable {
    
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var heartrate: Double
    @Persisted var timestamp: Date
    @Persisted var scanid: UUID?
    @Persisted var detected: Bool
    
    override class func primaryKey() -> String? {
        "id"
    }
}
