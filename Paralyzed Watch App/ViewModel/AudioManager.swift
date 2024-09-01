//
//  AudioManager.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 28.08.24.
//

import Foundation
import AVFoundation
import CoreML
import SoundAnalysis

class AudioManager: ObservableObject {
    
    var resultsObserver = ResultsObserver()
    
    var audioRecorder: AVAudioRecorder?
    var recordingSession: AVAudioSession!
    var timerTEST: Timer?
    


    /// An observer that receives results from a classify sound request.
    class ResultsObserver: NSObject, SNResultsObserving {
        static var prediction = ""
        static var counterPerCycle = 0
        
        /// Notifies the observer when a request generates a prediction.
        func request(_ request: SNRequest, didProduce result: SNResult) {
            // Downcast the result to a classification result.
            guard let result = result as? SNClassificationResult else  { return }
            
            
            // Get the prediction with the highest confidence.
            guard let classification = result.classifications.first else { return }
            
            
            // Convert the confidence to a percentage string.
            let percent = classification.confidence * 100.0
            let percentString = String(format: "%.2f%%", percent)
            
            
            // Print the classification's name (label) with its confidence.
            print("\(classification.identifier): \(percentString) confidence.\n")
            
            AudioManager.ResultsObserver.prediction = classification.identifier
            
            TimerManager.setPrediction(prediction: AudioManager.ResultsObserver.prediction)
            
        }
        
        /// Notifies the observer when a request generates an error.
        func request(_ request: SNRequest, didFailWithError error: Error) {
            print("The analysis failed: \(error.localizedDescription)")
        }


        /// Notifies the observer when a request is complete.
        func requestDidComplete(_ request: SNRequest) {
            print("The request completed successfully!")
            if AudioManager.ResultsObserver.prediction == "fast"{
                AudioManager.ResultsObserver.counterPerCycle = 99
            }else {
                AudioManager.ResultsObserver.counterPerCycle += 1
            }
        }
    }
    
    /// Creates an analyzer for an audio file.
    /// - Parameter audioFileURL: The URL to an audio file.
    func createAnalyzer(audioFileURL: URL) -> SNAudioFileAnalyzer? {
        return try? SNAudioFileAnalyzer(url: audioFileURL)
    }
    
    
    func startscanning() {
        // Einrichten der Audio-Session
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.record, mode: .default)
            try recordingSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Fehler beim Einrichten der Audio-Session: \(error.localizedDescription)")
            return
        }
        
        // Pfad zur temporären Audiodatei
        let audioFileName = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tempRecording.wav")
        
        // Aufnahme-Einstellungen
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM), // WAV-Format
            AVSampleRateKey: 16000, // 16 kHz
            AVNumberOfChannelsKey: 1, // Single Channel
            AVLinearPCMBitDepthKey: 16, // 16-Bit-Auflösung
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false
        ]
        
        do {
            // Audioaufnahme starten
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder?.record(forDuration: 5) // Aufnahme für 5 Sekunden

            // Timer zur Überwachung der 5-Sekunden-Aufnahme
            timerTEST = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: false) { _ in
                // Aufnahme stoppen und Datei hochladen
                self.audioRecorder?.stop()
                let audioFileURL = self.audioRecorder!.url
                

                
                do {
                    // Use a default model configuration.
                    let defaultConfig = MLModelConfiguration()

                    // Create an instance of the sound classifier's wrapper class.
                    let soundClassifier = try AudioML_v2(configuration: defaultConfig)

                    // Create a classify sound request that uses the custom sound classifier.
                    let classifySoundRequest = try SNClassifySoundRequest(mlModel: soundClassifier.model)
                    
                    let audioFileAnalyzer = self.createAnalyzer(audioFileURL: audioFileURL)
                    // Add a request to analyze.
                    try audioFileAnalyzer!.add(classifySoundRequest, withObserver: self.resultsObserver)
                    
                    audioFileAnalyzer?.analyze()
                    
                    print(AudioManager.ResultsObserver.counterPerCycle)
                    if (AudioManager.ResultsObserver.counterPerCycle < 3){
                        self.startscanning()
                    }else {
                        AudioManager.ResultsObserver.counterPerCycle = 0
                    }
                    
                } catch {
                    print("Fehler bei der Initialisierung des Modells oder der Klassifizierungsanfrage: \(error.localizedDescription)")
                }
                
                
            }
        } catch {
            print("Fehler beim Starten der Aufnahme: \(error.localizedDescription)")
        }
        
    }
    
}
