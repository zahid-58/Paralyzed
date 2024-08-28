//
//  ContentView.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 28.01.24.
//

import SwiftUI
import SwiftData
import RealmSwift


struct StartStopView: View {
    @StateObject private var healthManager = HealthManager()
    @State private var isActivated: Bool = false
    @State private var showImpactNotificationView = false
    @State private var motionActive: Bool = false
    @StateObject private var motionManager = MotionManager()
    @StateObject private var motionDataRecorder = MotionDataRecorder()
    @AppStorage("isWelcomeScreenOver") var isWelcomeScreenOver = false
    
    
    @StateObject private var audioManager = AudioManager()
    
    
    var body: some View {
        NavigationView {
            VStack {
                if !isActivated {
                    Button("Tap to activate") {
                        isActivated = true
                        //healthManager.requestAuthorization()
                        //uploadRealmToDiscord()
                        
                        // Verzögere die Ausführung des nachfolgenden Codes um 2 Sekunden
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            
                            //motionManager.recordAndUploadAudioToDiscord()
                            
                            audioManager.startscanning()

                        }
                        
                        //createAndUploadMotionDataFiles(webhookURL: "https://discord.com/api/webhooks/1223418868467499199/UOAUGjmezHHkJNbKp0yRfX7M4Bu9Fk5gjYmFy_e-pydLym1lLWwg0blPEN12RZ5ETadi")
                        
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .fontWeight(.bold)
                    .padding()
                    Text("Status:") + Text(" is deactivated").foregroundColor(.red)
                } else {
                    Button("Tap to deactivate") {
                        isActivated = false
                        healthManager.stopMonitoringAndTimer()
                        motionManager.stopMonitoring()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .fontWeight(.bold)
                    .padding()
                    Text("Status:") + Text(" is activated").foregroundColor(.green)
                }
                
                Text("Herzfrequenz: \(healthManager.heartRate, specifier: "%.0f") BPM")
                    .onChange(of: healthManager.averageHeartRate) { newValue in
                        if newValue > Config.loadHeartrateLimit() {
                            healthManager.stopMonitoringAndTimer()
                            healthManager.isMonitoring = false
                            motionManager.startMonitoring(for: 10)
                            motionActive = true
                        }
                    }
                
                if motionActive {
                    Text("Bewegungsdaten werden gescannt...")
                        .onChange(of: motionManager.motionNotDetected) { newValue in
                            if newValue == 1 {
                                motionManager.motionNotDetected = 0
                                isActivated = false
                                showImpactNotificationView = true
                                motionManager.stopMonitoring()
                                motionActive = false
                            }
                            
                            if newValue == 2 {
                                print("Bewegung erkannt, es geht weiter")
                                healthManager.requestAuthorization()
                                motionActive = false
                            }
                        }
                }
                
//                if motionActive {
//                    Text("Bewegungsdaten werden gescannt...")
//                        .onChange(of: motionManager.countdownIterate) { newValue in
//
//                                
//                                isActivated = false
//                                motionManager.stopMonitoring()
//                                motionActive = false
//
//                            
//                        }
//                }
                
                
                
            }
            .navigationBarBackButtonHidden()
            .fullScreenCover(isPresented: $showImpactNotificationView) {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all) // Schwarzer Hintergrund
                    ImpactNotificationView(showImpactNotificationView: $showImpactNotificationView)
                }
            }
            .fullScreenCover(isPresented: .constant(!isWelcomeScreenOver)) {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all) // Schwarzer Hintergrund
                    WelcomeView1(isWelcomeScreenOver: $isWelcomeScreenOver)
                        .navigationBarHidden(true)
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    func uploadRealmToDiscord() {
        let fileManager = FileManager.default
        
        // Pfad zum Documents-Verzeichnis abrufen
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Pfad zur default.realm Datei
        let realmFileURL = documentsDirectory.appendingPathComponent("default.realm")
        
        // Überprüfen, ob die Datei existiert
        guard fileManager.fileExists(atPath: realmFileURL.path) else {
            print("Die Datei default.realm existiert nicht.")
            return
        }
        
        // URL des Discord Webhooks
        let webhookURL = URL(string: "https://discord.com/api/webhooks/1223418868467499199/UOAUGjmezHHkJNbKp0yRfX7M4Bu9Fk5gjYmFy_e-pydLym1lLWwg0blPEN12RZ5ETadi")!
        
        // Dateiinhalt lesen
        do {
            let fileData = try Data(contentsOf: realmFileURL)
            
            // Multipart-Formdaten erstellen
            var request = URLRequest(url: webhookURL)
            request.httpMethod = "POST"
            
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var body = Data()
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"default.realm\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
            body.append(fileData)
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            request.httpBody = body
            
            // Datei an Discord senden
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Fehler beim Hochladen der Datei: \(error.localizedDescription)")
                    return
                }
                
                guard let response = response as? HTTPURLResponse, response.statusCode == 204 else {
                    print("Fehlerhafte Antwort vom Server")
                    return
                }
                
                print("Datei erfolgreich hochgeladen!")
            }
            
            task.resume()
            
        } catch {
            print("Fehler beim Lesen der Datei: \(error.localizedDescription)")
        }
    }
    
    
//    // Funktion zum Erstellen von 600er-Paketen aus den Daten und Hochladen als JSON-Dateien auf Discord mit einer Sekunde Verzögerung
//    func createAndUploadMotionDataFiles(webhookURL: String) {
//        let realm = try! Realm()
//        
//        // Hole alle MotionDataNormal-Objekte aus der Datenbank
//        let motionDataResults = realm.objects(MotionDataSchnell2.self)
//        
//        // Temporäre Liste, um die Daten zu sammeln
//        var currentDataBatch: [[String: Double]] = []
//        
//        // Variable zum Zählen der Pakete
//        var batchCount = 0
//        
//        for (index, motionData) in motionDataResults.enumerated() {
//            let dataPoint = ["x": motionData.x, "y": motionData.y, "z": motionData.z]
//            currentDataBatch.append(dataPoint)
//            
//            // Wenn das Paket 600 Einträge erreicht hat oder wir das Ende der Daten erreicht haben
//            if currentDataBatch.count == 600 || index == motionDataResults.count - 1 {
//                // Wenn das Paket weniger als 600 Einträge hat, fülle es auf
//                while currentDataBatch.count < 600 {
//                    currentDataBatch.append(["x": 0.0, "y": 0.0, "z": 0.0])
//                }
//                
//                // Konvertiere das Array in JSON-Daten
//                guard let jsonData = try? JSONSerialization.data(withJSONObject: currentDataBatch, options: .prettyPrinted) else {
//                    print("Fehler: Konnte JSON-Daten nicht konvertieren")
//                    return
//                }
//                
//                // Erstelle einen eindeutigen Dateinamen
//                let fileName = "motion_data_file_\(batchCount).json"
//                
//                // Lade die JSON-Daten hoch
//                uploadJSONFileToDiscord(jsonData: jsonData, fileName: fileName, webhookURL: webhookURL)
//                
//                // Warte eine Sekunde, bevor die nächste Datei hochgeladen wird
//                Thread.sleep(forTimeInterval: 3.0)
//                
//                // Setze das aktuelle Paket zurück und erhöhe den Batch-Zähler
//                currentDataBatch = []
//                batchCount += 1
//            }
//        }
//    }

//    // Funktion zum Hochladen der JSON-Daten als Datei über Discord Webhook
//    func uploadJSONFileToDiscord(jsonData: Data, fileName: String, webhookURL: String) {
//        // URL des Discord Webhooks
//        guard let url = URL(string: webhookURL) else { return }
//        
//        // Multipart/form-data Anfrage erstellen
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        
//        // Zufällige Grenze für die Multipart-Daten
//        let boundary = "Boundary-\(UUID().uuidString)"
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        
//        // Dateiinhalt als Teil der Multipart-Daten
//        var body = Data()
//        body.append("--\(boundary)\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
//        body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
//        body.append(jsonData)
//        body.append("\r\n".data(using: .utf8)!)
//        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
//        
//        request.httpBody = body
//        
//        // Führe den POST-Request aus
//        let session = URLSession.shared
//        session.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Fehler beim Hochladen: \(error.localizedDescription)")
//                return
//            }
//            print("JSON-Datei \(fileName) erfolgreich hochgeladen!")
//        }.resume()
//    }
    
    
}

#Preview {
    StartStopView()
}
