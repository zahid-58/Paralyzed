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
        
        func request(_ request: SNRequest, didProduce result: SNResult) {
            guard let result = result as? SNClassificationResult,
                  let classification = result.classifications.first else { return }
            
            let percent = classification.confidence * 100.0
            let percentString = String(format: "%.2f%%", percent)
            
            print("\(classification.identifier): \(percentString) confidence.\n")
            
            Self.prediction = classification.identifier
            TimerManager.setPrediction(prediction: Self.prediction)
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
            
            timerTEST = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: false) { [weak self] _ in
                self?.handleRecordingCompletion()
            }
        } catch {
            print("Fehler beim Starten der Aufnahme: \(error.localizedDescription)")
        }
    }
    
    private func setupAudioSession() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.record, mode: .default)
            try recordingSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Fehler beim Einrichten der Audio-Session: \(error.localizedDescription)")
        }
    }

    private func getTemporaryAudioFileURL() -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tempRecording.wav")
    }
    
    private func handleRecordingCompletion() {
        audioRecorder?.stop()
        guard let audioFileURL = audioRecorder?.url else { return }
        
        do {
            let soundClassifier = try AudioML_v2(configuration: MLModelConfiguration())
            let classifySoundRequest = try SNClassifySoundRequest(mlModel: soundClassifier.model)
            guard let audioFileAnalyzer = createAnalyzer(audioFileURL: audioFileURL) else { return }
            
            try audioFileAnalyzer.add(classifySoundRequest, withObserver: resultsObserver)
            audioFileAnalyzer.analyze()
            
            print(ResultsObserver.counterPerCycle)
            if ResultsObserver.counterPerCycle < 3 {
                startScanning()
            } else {
                ResultsObserver.counterPerCycle = 0
            }
        } catch {
            print("Fehler bei der Initialisierung des Modells oder der Klassifizierungsanfrage: \(error.localizedDescription)")
        }
    }
}
