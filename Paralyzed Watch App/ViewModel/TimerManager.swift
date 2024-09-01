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
    
    static var prediction = "" {
        didSet {
            // Sende eine Benachrichtigung, wenn die statische Variable geändert wird
            NotificationCenter.default.post(name: .predictionDidChange, object: nil)
        }
    }
    
    init(healthManager: HealthManager, audioManager: AudioManager) {
        self.healthManager = healthManager
        self.audioManager = audioManager
    }
    
    
    func waitForTenSeconds(completion: @escaping () -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 10) {
            completion()
        }
    }
    
    static func setPrediction(prediction: String) {
        TimerManager.prediction = prediction
    }
    
    func startCycle() {
        
        waitForTenSeconds {
            self.healthManager.requestAuthorization()
            DispatchQueue.main.async() {
                self.audioManager.startscanning()
            }
        }
        
    }
    

}

extension Notification.Name {
    static let predictionDidChange = Notification.Name("predictionDidChange")
}
