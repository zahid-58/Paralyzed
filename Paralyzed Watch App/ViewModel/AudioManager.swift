//
//  AudioManager.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 28.08.24.
//

import AVFoundation
import CoreML
import SoundAnalysis

extension Notification.Name {
    static let predictionDidChange = Notification.Name("predictionDidChange")
}

class AudioManager: ObservableObject {
    var resultsObserver = ResultsObserver()
    var audioRecorder: AVAudioRecorder?
    var recordingSession: AVAudioSession!
    var timer: Timer?
    
    // Einmalige Initialisierung des Modells
    let soundClassifier: AudioML_v2

    init() {
        // Initialisiere das Modell einmal in der Initialisierungsfunktion
        do {
            let configuration = MLModelConfiguration()
            soundClassifier = try AudioML_v2(configuration: configuration)
        } catch {
            // Hier ist eine alternative Fehlerbehandlung erforderlich
            fatalError("Fehler beim Initialisieren des Modells: \(error.localizedDescription)")
        }
    }

    /// An observer that receives results from a classify sound request.
    class ResultsObserver: NSObject, SNResultsObserving {
        static var prediction = "" {
            didSet {
                // Sende eine Benachrichtigung, wenn die statische Variable geändert wird
                NotificationCenter.default.post(name: .predictionDidChange, object: nil)
            }
        }

        static var counterPerCycle = 0
        
        func request(_ request: SNRequest, didProduce result: SNResult) {
            guard let result = result as? SNClassificationResult,
                  let classification = result.classifications.first else { return }
            
            let percent = classification.confidence * 100.0
            let percentString = String(format: "%.2f%%", percent)
            
            print("\(classification.identifier): \(percentString) confidence.\n")
            
            Self.prediction = classification.identifier
        }
        
        func request(_ request: SNRequest, didFailWithError error: Error) {
            print("The analysis failed: \(error.localizedDescription)")
        }

        func requestDidComplete(_ request: SNRequest) {
            print("The request completed successfully!")
            Self.counterPerCycle = (Self.prediction == "fast") ? 99 : Self.counterPerCycle + 1
        }
    }
    
    /// Creates an analyzer for an audio file.
    func createAnalyzer(audioFileURL: URL) -> SNAudioFileAnalyzer? {
        return try? SNAudioFileAnalyzer(url: audioFileURL)
    }
    
    func startScanning() {
        setupAudioSession()
        let audioFileName = getTemporaryAudioFileURL()

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder?.record(forDuration: 5)
            
            timer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: false) { [weak self] _ in
                self?.handleRecordingCompletion()
            }
        } catch {
            handleError(error)
        }
    }
    
    private func setupAudioSession() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.record, mode: .default)
            try recordingSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            handleError(error)
        }
    }

    private func getTemporaryAudioFileURL() -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tempRecording.wav")
    }
    
    private func handleRecordingCompletion() {
        audioRecorder?.stop()
        guard let audioFileURL = audioRecorder?.url else { return }
        
        do {
            let classifySoundRequest = try SNClassifySoundRequest(mlModel: soundClassifier.model)
            guard let audioFileAnalyzer = createAnalyzer(audioFileURL: audioFileURL) else { return }
            
            try audioFileAnalyzer.add(classifySoundRequest, withObserver: resultsObserver)
            audioFileAnalyzer.analyze()
            
            print(ResultsObserver.counterPerCycle)
            if ResultsObserver.counterPerCycle < 3 {
                startScanning()
            } else {
                ResultsObserver.counterPerCycle = 0
                timer?.invalidate()
                timer = nil
                resetAudioSession() // Session zurücksetzen
                // Lösche die temporäre Datei nach der Analyse
                deleteTemporaryAudioFile(at: audioFileURL)
            }
            

            
        } catch {
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        switch error {
        case let error as AudioManagerError:
            switch error {
            case .audioSessionFailed(let message):
                print("Audio Session Error: \(message)")
                // Mögliche Maßnahme: Versuche, die Sitzung neu zu starten oder den Benutzer zu benachrichtigen
            case .recorderFailed(let message):
                print("Recorder Error: \(message)")
                // Mögliche Maßnahme: Versuche, die Aufnahme erneut zu starten
            case .fileNotFound(let message):
                print("File Error: \(message)")
                // Mögliche Maßnahme: Überprüfe, ob die Datei existiert und zugänglich ist
            case .analyzerCreationFailed:
                print("Analyzer Error: Failed to create audio file analyzer.")
                // Mögliche Maßnahme: App-Status aktualisieren oder erneut versuchen
            case .classificationFailed(let message):
                print("Classification Error: \(message)")
                // Mögliche Maßnahme: Überprüfe das Modell oder starte die Analyse erneut
            }

        default:
            print("Unknown Error: \(error.localizedDescription)")
            // Allgemeine Maßnahme: Zeige eine allgemeine Fehlermeldung an oder logge den Fehler
        }
    }
    
    /// Löscht die temporäre Audiodatei nach Abschluss der Analyse
    private func deleteTemporaryAudioFile(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            print("Temporäre Audiodatei erfolgreich gelöscht: \(url.lastPathComponent)")
        } catch {
            print("Fehler beim Löschen der temporären Audiodatei: \(error.localizedDescription)")
        }
    }
    
    func resetAudioSession() {
        do {
            // Deaktiviere die aktuelle Audio-Session
            try recordingSession.setActive(false, options: .notifyOthersOnDeactivation)
            print("Audio-Session wurde deaktiviert.")
        } catch {
            print("Fehler beim Deaktivieren der Audio-Session: \(error.localizedDescription)")
        }
        
        // Lösche die Audio-Session
        recordingSession = nil
        
        // Erstelle die Audio-Session neu
        setupAudioSession()
    }
    
    
}

enum AudioManagerError: Error {
    case audioSessionFailed(String)
    case recorderFailed(String)
    case fileNotFound(String)
    case analyzerCreationFailed
    case classificationFailed(String)
}
