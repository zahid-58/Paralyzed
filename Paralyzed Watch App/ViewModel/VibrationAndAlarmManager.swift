//
//  VibrationAndAlarmManager.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 25.02.24.
//

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
        
        // Starte den Timer auf dem Hauptthread
        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let currentTime = Date()
            guard let startTime = self.startTime else { return }
            let elapsedTime = currentTime.timeIntervalSince(startTime)
            
            if elapsedTime >= 5 * 60 {
                print("5 Minuten sind um, Timer wird beendet")
                self.stopTimer()
                return
            }

            if self.doneButtonClicked {
                print("Done Button wurde geklickt")
                self.stopTimer()
            } else {
                print("Done Button wurde nicht geklickt, iteriere weiter...")
                switch type {
                case .vibration:
                    self.activateVibration()
                case .alarm:
                    self.stopAllAudioSessions()
                    self.activateAlarm()
                case .both:
                    self.activateVibration()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.stopAllAudioSessions()
                        self.activateAlarm()
                    }
                }
            }
        }
        
        // Sicherstellen, dass der Timer im RunLoop läuft
        RunLoop.current.add(self.timer!, forMode: .common)
    }

    func activateVibration() {
        WKInterfaceDevice.current().play(.failure)
        print("Vibration aktiviert")
    }

    func activateAlarm() {
        guard let soundURL = Bundle.main.url(forResource: "alarm", withExtension: "mp3") else {
            print("Audio-Datei nicht gefunden")
            return
        }
        
        do {
            // Neue Audiositzung konfigurieren
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)

            // Audio-Player vorbereiten und abspielen
            self.audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            self.audioPlayer?.prepareToPlay()
            self.audioPlayer?.play()
        } catch {
            print("Fehler beim Abspielen der Audio-Datei: \(error)")
        }
        
        print("Alarm wird abgespielt")
    }

    // Funktion zum Beenden aller aktiven Audiositzungen
    func stopAllAudioSessions() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            print("Alle Audiositzungen wurden deaktiviert.")
        } catch {
            print("Fehler beim Deaktivieren der Audiositzungen: \(error)")
        }
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

