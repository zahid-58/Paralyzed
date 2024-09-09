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
    static var pressedToDisable = false
    static var isRunning = false
    
    init(healthManager: HealthManager, audioManager: AudioManager) {
        self.healthManager = healthManager
        self.audioManager = audioManager
    }
    
    
    func waitToStartCycle(completion: @escaping () -> Void) {
        Self.isRunning = true
        DispatchQueue.global().asyncAfter(deadline: .now() + 20) {
            Self.isRunning = false
            completion()
        }
    }
    
    func startCycle() {
        
        waitToStartCycle {
            if Self.pressedToDisable == false{
                self.healthManager.requestAuthorization()
                DispatchQueue.main.async() {
                    self.audioManager.startScanning()
                }
            }else {
                Self.pressedToDisable = false
            }
        }
    }
}
