//
//  MotionDataSchnell.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 26.08.24.
//

import Foundation
import RealmSwift


class MotionDataSchnell: Object, Identifiable {
    
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var x: Double
    @Persisted var y: Double
    @Persisted var z: Double
    @Persisted var label: String
    
    override class func primaryKey() -> String? {
        "id"
    }
    
    
}
