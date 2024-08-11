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
    // Verwendet eine @Published Eigenschaft, um Änderungen am aktiven Toggle zu überwachen.
    // 1 für Vibration, 2 für Alarm, 3 für Vibration und Alarm
    @Published var activeToggle: Int = 1
    @Published var doneButtonClicked = false
    var audioPlayer: AVAudioPlayer?
    
    private var timer: Timer?


    // Funktionen, um die entsprechenden Aktionen auszuführen.
    func activateVibration() {
        doneButtonClicked = false

        
        DispatchQueue.main.async {
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in

                if self!.doneButtonClicked {
                    
                    print("done wurde geklickt")
                    self!.timer?.invalidate()
                    self!.timer = nil
                    self!.doneButtonClicked = false
                    
                }else{
                    
                    print("done wurde NICHT geklickt")

                    // Implementiere hier die Logik für die Aktivierung der Vibration.
                    // Dies könnte z.B. das Auslösen eines Haptik-Feedbacks beinhalten.
                    WKInterfaceDevice.current().play(.failure)
                    
                    print("Vibration activated")
                    
                }

                
            }
        }
        
        
    }
    
    func activateAlarm() {
        doneButtonClicked = false
        
        
        DispatchQueue.main.async {
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in

                if self!.doneButtonClicked {
                    
                    print("done wurde geklickt")
                    self!.timer?.invalidate()
                    self!.timer = nil
                    self!.doneButtonClicked = false
                    
                }else{
                    
                    print("done wurde NICHT geklickt")

                    guard let soundURL = Bundle.main.url(forResource: "alarm", withExtension: "mp3") else {
                        print("Audio file not found")
                        return
                    }
                    
                    do {
                        self!.audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                        self!.audioPlayer?.play()
                    } catch {
                        print("Failed to play audio: \(error)")
                    }
                    
                    print("Alarm Sound Playing")
                    
                }

                
            }
        }
    }
    
    func activateBoth() {
        doneButtonClicked = false
        
        DispatchQueue.main.async {
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in

                if self!.doneButtonClicked {
                    
                    print("done wurde geklickt")
                    self!.timer?.invalidate()
                    self!.timer = nil
                    self!.doneButtonClicked = false
                    
                }else{
                    
                    print("done wurde NICHT geklickt")
                    print("IST IN ACTIVEBOTH")
                    // Hier könntest du beide Aktionen gleichzeitig ausführen.
                    
                    WKInterfaceDevice.current().play(.failure)
                    
                    print("Vibration activated")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        guard let soundURL = Bundle.main.url(forResource: "alarm", withExtension: "mp3") else {
                            print("Audio file not found")
                            return
                        }
                        
                        do {
                            self!.audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                            self!.audioPlayer?.play()
                        } catch {
                            print("Failed to play audio: \(error)")
                        }
                        
                        print("Alarm Sound Playing")
                    }
                    
                }

                
            }
        }
        


    }
    
    
}

