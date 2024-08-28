//
//  MotionManager.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 13.06.24.
//

import CoreMotion
import Foundation
import RealmSwift
import CoreML
import AVFoundation

class MotionManager: ObservableObject{
    let motionManager = CMMotionManager()
    var timer: Timer?
    @Published var motionNotDetected = 0 // Variable, um festzustellen, ob Bewegung erkannt wurde
    var xValues: [Double] = []
    var yValues: [Double] = []
    var zValues: [Double] = []
    
    @ObservedResults(MotionData.self) var motiondb
    
    
    @Published var countdownIterate = 0
    
    
    var audioRecorder: AVAudioRecorder?
    var recordingSession: AVAudioSession!
    var timerTEST: Timer?

    // Funktion zum Starten der Bewegungsüberwachung
    func startMonitoring(for duration: TimeInterval) {
        guard motionManager.isAccelerometerAvailable else {
            print("Beschleunigungsmesser nicht verfügbar.")
            return
        }
        motionNotDetected = 0
        xValues.removeAll()
        yValues.removeAll()
        zValues.removeAll()

        motionManager.accelerometerUpdateInterval = 1.0 / 60.0 // Daten werden 2 Mal pro Sekunde aktualisiert
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            guard let data = data else {
                print("Fehler beim Abrufen von Accelerometer-Daten: \(error?.localizedDescription ?? "Unbekannter Fehler")")
                return
            }
            
            print("Aktuelle Beschleunigungsdaten: x = \(data.acceleration.x), y = \(data.acceleration.y), z = \(data.acceleration.z)")
            
            // Speichere die x, y, z Werte in den entsprechenden Listen
            self?.xValues.append(data.acceleration.x)
            self?.yValues.append(data.acceleration.y)
            self?.zValues.append(data.acceleration.z)
            
            let motionRow = MotionData()
            
            motionRow.x = data.acceleration.x
            motionRow.y = data.acceleration.y
            motionRow.z = data.acceleration.z
            motionRow.timestamp = Date()
            motionRow.scanid = HealthManager.scanid
            motionRow.detected = false
            
            self?.$motiondb.append(motionRow)
            
//            let motionRowNormal = MotionDataNormal2()
//            
//            motionRowNormal.x = data.acceleration.x
//            motionRowNormal.y = data.acceleration.y
//            motionRowNormal.z = data.acceleration.z
//            motionRowNormal.label = "normal"
//            
//            self?.$motiondbforML.append(motionRowNormal)
            
//            let motionRowSchnell = MotionDataSchnell2()
//            
//            motionRowSchnell.x = data.acceleration.x
//            motionRowSchnell.y = data.acceleration.y
//            motionRowSchnell.z = data.acceleration.z
//            motionRowSchnell.label = "schnell"
//            
//            self?.$motiondbforML2.append(motionRowSchnell)

        }

        // Timer einrichten, um die Überwachung zu stoppen
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.stopMonitoring()
            self.calculateAndPrintAverageDifferences()
            //self.predictActivity()
            if self.motionNotDetected == 1 {
                print("Keine Bewegung erkannt.")
                
                // Alle relevanten Datensätze in der MotionData-Tabelle auf detected = true setzen
//                if let realm = try? Realm() {
//                    try? realm.write {
//                        let motionResults = realm.objects(MotionData.self).filter("scanid == %@", HealthManager.scanid!)
//                        motionResults.setValue(true, forKey: "detected")
//                    }
//                }
                
                // Alle relevanten Datensätze in der HeartRateData-Tabelle auf detected = true setzen
//                if let realm = try? Realm() {
//                    try? realm.write {
//                        let heartRateResults = realm.objects(HeartRateData.self).filter("scanid == %@", HealthManager.scanid!)
//                        heartRateResults.setValue(true, forKey: "detected")
//                    }
//                }
                
            }
            
            if self.motionNotDetected == 2 {
                print("Bewegung erkannt.")
            }
            
            countdownIterate = countdownIterate + 1
            
        }
    }

    // Funktion zum Stoppen der Überwachung
    func stopMonitoring() {
        motionManager.stopAccelerometerUpdates()
        timer?.invalidate()
        timer = nil
        motionNotDetected = 0
        
        print("MOTION STOPPED")
    }

    func calculateAndPrintAverageDifferences() {
        var averageDifferenceList: [Int] = []
        
        averageDifferenceList.append(printAverageDifference(for: xValues, axis: "X"))
        averageDifferenceList.append(printAverageDifference(for: yValues, axis: "Y"))
        averageDifferenceList.append(printAverageDifference(for: zValues, axis: "Z"))
        
        if averageDifferenceList.contains(2) {
            motionNotDetected = 2
        }else{
            motionNotDetected = 1
        }
    
    }

    func printAverageDifference(for values: [Double], axis: String) -> Int{
        guard let firstValue = values.first else { return -1}
        
        // Liste für die Speicherung der absoluten Differenzen
        var differences: [Double] = []

        // Starte die Schleife beim zweiten Wert (index 1)
        for value in values.dropFirst() {
            let difference = abs(firstValue - value)
            differences.append(difference)
        }
        
        // Summiere alle Differenzen
        let sumOfDifferences = differences.reduce(0.0, +)

        // Anzahl der Differenzen
        let numberOfDifferences = Double(differences.count)

        // Berechne den Durchschnitt der Differenzen
        // Prüfe, ob die Anzahl der Differenzen größer als 0 ist, um Division durch Null zu vermeiden
        let averageDifference = numberOfDifferences > 0 ? sumOfDifferences / numberOfDifferences : 0.0
        
        print("Durchschnittliche absolute Differenz für Achse \(axis): \(String(format: "%.4f", averageDifference))")
        
        if averageDifference < 0.1 {
            return 1
        }else{
            return 2
        }
        
    }
    
//    // Funktion zur Vorhersage der Aktivität
//    func predictActivity() {
//        guard let xArray = createMLMultiArray(from: xValues),
//              let yArray = createMLMultiArray(from: yValues),
//              let zArray = createMLMultiArray(from: zValues),
//              let stateIn = try? MLMultiArray(shape: [400], dataType: .double) else {
//            print("Error creating MLMultiArray for inputs.")
//            return
//        }
//
//        do {
//            // Erstelle das Input-Objekt für das Modell
//            let config = MLModelConfiguration()
//            let model = try MotionML(configuration: config)
//            
//            let input = MotionMLInput(x: xArray, y: yArray, z: zArray, stateIn: stateIn)
//            
//            // Führe die Vorhersage aus
//            let prediction = try model.prediction(input: input)
//            
//            // Vorhersage ausgeben
//            print("Predicted activity: \(prediction.label)")
//            
//        } catch {
//            print("Error making prediction: \(error)")
//        }
//    }
//    
//    func createMLMultiArray(from array: [Double]) -> MLMultiArray? {
//        // Limitiere das Array auf maximal 600 Einträge
//        let limitedArray = array.count > 600 ? Array(array.prefix(600)) : array
//        
//        do {
//            let mlArray = try MLMultiArray(shape: [NSNumber(value: limitedArray.count)], dataType: .double)
//            for (index, value) in limitedArray.enumerated() {
//                mlArray[index] = NSNumber(value: value)
//            }
//            return mlArray
//        } catch {
//            print("Error creating MLMultiArray: \(error)")
//            return nil
//        }
//    }
    
    func recordAndUploadAudioToDiscord() {
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
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
                // Aufnahme stoppen und Datei hochladen
                self.audioRecorder?.stop()
                if let audioFileURL = self.audioRecorder?.url {
                    do {
                        let audioData = try Data(contentsOf: audioFileURL)
                        self.uploadToDiscord(audioData: audioData, fileName: "recording.wav")
                    } catch {
                        print("Fehler beim Laden der Audiodatei: \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            print("Fehler beim Starten der Aufnahme: \(error.localizedDescription)")
        }
    }

    // Funktion zum Hochladen der Audio-Daten über Discord Webhook
    func uploadToDiscord(audioData: Data, fileName: String) {
        let webhookURL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"
        guard let url = URL(string: webhookURL) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Fehler beim Hochladen: \(error.localizedDescription)")
                return
            }
            print("Audiodatei erfolgreich hochgeladen!")
        }.resume()
    }

    
    
}
