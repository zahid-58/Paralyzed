//
//  ManagerProvider.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 02.08.24.
//

import Foundation

class ManagerProvider: ObservableObject {
    
    //Eine statische Instanz auf Klassenebene von Managerprovider die in anderen Klassen verwendet wird
    static let shared = ManagerProvider()
    
    //Deklarierung alle Manager die verwendet werden sollen
    @Published var motionManager: MotionManager
    @Published var healthManager: HealthManager
    
    
    private init() {
        self.motionManager = MotionManager()
        self.healthManager = HealthManager()
    }
    
}
