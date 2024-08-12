//
//  VibrationAndAlarmManager.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 25.02.24.
//

import Foundation
import AVFoundation
import WatchKit

class VibrationAndAlarmManager: ObservableObject {
    @Published var activeToggle: Int = Config.loadSettingsToggle()
    @Published var doneButtonClicked = false
    var audioPlayer: AVAudioPlayer?
    var startTime: Date?
    
    private var timer: Timer?

    func startAction(type: ActionType) {
        doneButtonClicked = false
        self.startTime = Date()
        
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                
                let currentTime = Date()
                guard let startTime = self.startTime else { return }
                let elapsedTime = currentTime.timeIntervalSince(startTime)
                
                if elapsedTime >= 5 * 60 {
                    print("5 Minuten sind um, Timer wird beendet")
                    self.timer?.invalidate()
                    self.timer = nil
                    return
                }

                if self.doneButtonClicked {
                    print("done wurde geklickt")
                    self.timer?.invalidate()
                    self.timer = nil
                    self.doneButtonClicked = false
                } else {
                    print("done wurde NICHT geklickt")
                    switch type {
                    case .vibration:
                        self.activateVibration()
                    case .alarm:
                        self.activateAlarm()
                    case .both:
                        self.activateVibration()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.activateAlarm()
                        }
                    }
                }
            }
        }
    }

    func activateVibration() {
        WKInterfaceDevice.current().play(.failure)
        print("Vibration activated")
    }

    func activateAlarm() {
        guard let soundURL = Bundle.main.url(forResource: "alarm", withExtension: "mp3") else {
            print("Audio file not found")
            return
        }
        
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            self.audioPlayer?.play()
        } catch {
            print("Failed to play audio: \(error)")
        }
        
        print("Alarm Sound Playing")
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
}

enum ActionType {
    case vibration
    case alarm
    case both
}

