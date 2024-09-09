//
//  TimerManager.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 01.09.24.
//

import Foundation

class TimerManager: ObservableObject {
    
    private var healthManager: HealthManager
    private var audioManager: AudioManager
    static var tabbedToDisable = false
    static var isRunning = false
    
    init(healthManager: HealthManager, audioManager: AudioManager) {
        self.healthManager = healthManager
        self.audioManager = audioManager
    }
    
    
    func waitForTenSeconds(completion: @escaping () -> Void) {
        Self.isRunning = true
        DispatchQueue.global().asyncAfter(deadline: .now() + 20) {
            Self.isRunning = false
            completion()
        }
    }
    
    func startCycle() {
        
        waitForTenSeconds {
            if Self.tabbedToDisable == false{
                self.healthManager.requestAuthorization()
                DispatchQueue.main.async() {
                    self.audioManager.startScanning()
                }
            }else {
                Self.tabbedToDisable = false
            }
        }
    }
}
