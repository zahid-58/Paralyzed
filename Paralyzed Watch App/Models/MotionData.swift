//
//  MotionData.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 25.08.24.
//

import Foundation
import RealmSwift

class MotionData: Object, Identifiable {
    
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var x: Double
    @Persisted var y: Double
    @Persisted var z: Double
    @Persisted var timestamp: Date
    @Persisted var scanid: UUID?
    @Persisted var detected: Bool
    
    override class func primaryKey() -> String? {
        "id"
    }
    
    
}
