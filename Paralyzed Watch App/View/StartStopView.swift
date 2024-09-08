//
//  ContentView.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 28.01.24.
//

import SwiftUI

struct StartStopView: View {
    @StateObject private var healthManager = HealthManager()
    @StateObject private var motionManager = MotionManager()
    @StateObject private var audioManager = AudioManager()

    @State private var isActivated: Bool = false
    @State private var showImpactNotificationView = false
    @State private var motionActive: Bool = false
    @State private var audioActive: Bool = false

    @AppStorage("isWelcomeScreenOver") var isWelcomeScreenOver = false
    
    
    var body: some View {
        let timerManager = TimerManager(healthManager: healthManager, audioManager: audioManager)
        NavigationView {
            VStack {
                if !isActivated {
                    Button("Tap to activate") {

                        isActivated = true
                        
                        //uploadRealmToDiscord()
                        //deleteRealmDatabase()
                        if TimerManager.isRunning{
                            print("TimerManager Cycle besteht noch, und wird weiter verwendet")
                            TimerManager.tabbedToDisable = false
                            
                        }else{
                            print("Button startet TimerManager Cycle")
                            timerManager.startCycle()
                        }

                        audioActive = true

                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .fontWeight(.bold)
                    .padding()
                    Text("Status:") + Text(" is deactivated").foregroundColor(.red)
                } else {
                    Button("Tap to deactivate") {
                        if TimerManager.isRunning{
                            TimerManager.tabbedToDisable = true
                        }
                        
                        isActivated = false
                        healthManager.stopMonitoringHeartRate()
                        motionManager.stopMonitoring()
                        motionActive = false
                        AudioManager.ResultsObserver.counterPerCycle = 99
                        audioActive = false
                        
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .fontWeight(.bold)
                    .padding()
                    Text("Status:") + Text(" is activated").foregroundColor(.green)
                }
                
                Text("Herzfrequenz: \(healthManager.heartRate, specifier: "%.0f") BPM")
                    .onChange(of: healthManager.averageHeartRate) { newValue in
                        if newValue == 9999{
                            return
                        }
                        
                        
                        if newValue >= Config.loadHeartrateLimit() {
                            healthManager.isMonitoring = false
                            audioActive = false
                            motionManager.startMonitoring(for: 10)
                            motionActive = true
                        }else {
                            healthManager.isMonitoring = false
                            timerManager.startCycle()
                        }
                        
                        
                    }
                
                if audioActive {
                    Text("AI Audio Detection...")
                        .onReceive(NotificationCenter.default.publisher(for: .predictionDidChange)) { _ in
                        
                            if AudioManager.ResultsObserver.prediction == "fast" {
                                audioActive = false
                                healthManager.stopMonitoringHeartRate()
                                
                                if isActivated{
                                    motionManager.startMonitoring(for: 10)
                                    motionActive = true
                                }

                            }
                        }
                }


                
                if motionActive {
                    Text("Bewegungsdaten werden gescannt...")
                        .onChange(of: motionManager.motionStatus) { newValue in
                            if newValue == .noMovement {
                                motionManager.motionStatus = .undetermined
                                isActivated = false
                                showImpactNotificationView = true
                                motionManager.stopMonitoring()
                                motionActive = false
                            }
                            
                            if newValue == .movementDetected {
                                audioActive = true
                                timerManager.startCycle()
                                motionActive = false
                            }
                        }
                }
                
                
                
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
    
//    func uploadRealmToDiscord() {
//        let fileManager = FileManager.default
//        
//        // Pfad zum Documents-Verzeichnis abrufen
//        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
//        
//        // Pfad zur default.realm Datei
//        let realmFileURL = documentsDirectory.appendingPathComponent("default.realm")
//        
//        // Überprüfen, ob die Datei existiert
//        guard fileManager.fileExists(atPath: realmFileURL.path) else {
//            print("Die Datei default.realm existiert nicht.")
//            return
//        }
//        
//        // URL des Discord Webhooks
//        let webhookURL = URL(string: "https://discord.com/api/webhooks/1223418868467499199/UOAUGjmezHHkJNbKp0yRfX7M4Bu9Fk5gjYmFy_e-pydLym1lLWwg0blPEN12RZ5ETadi")!
//        
//        // Dateiinhalt lesen
//        do {
//            let fileData = try Data(contentsOf: realmFileURL)
//            
//            // Multipart-Formdaten erstellen
//            var request = URLRequest(url: webhookURL)
//            request.httpMethod = "POST"
//            
//            let boundary = UUID().uuidString
//            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//            
//            var body = Data()
//            
//            body.append("--\(boundary)\r\n".data(using: .utf8)!)
//            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"default.realm\"\r\n".data(using: .utf8)!)
//            body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
//            body.append(fileData)
//            body.append("\r\n".data(using: .utf8)!)
//            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
//            
//            request.httpBody = body
//            
//            // Datei an Discord senden
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                if let error = error {
//                    print("Fehler beim Hochladen der Datei: \(error.localizedDescription)")
//                    return
//                }
//                
//                guard let response = response as? HTTPURLResponse, response.statusCode == 204 else {
//                    print("Fehlerhafte Antwort vom Server")
//                    return
//                }
//                
//                print("Datei erfolgreich hochgeladen!")
//            }
//            
//            task.resume()
//            
//        } catch {
//            print("Fehler beim Lesen der Datei: \(error.localizedDescription)")
//        }
//    }
//    
//    func listFilesInDocumentsDirectory() {
//         let fileManager = FileManager.default
//         
//         // Pfad zum Documents-Verzeichnis abrufen
//        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
//         
//         do {
//             // Inhalte des Documents-Verzeichnisses auflisten
//             let fileURLs = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
//             
//             print("Inhalt des Documents-Verzeichnisses:")
//             for fileURL in fileURLs {
//                 print(fileURL.lastPathComponent)
//             }
//         } catch {
//             print("Fehler beim Auflisten der Dateien im Documents-Verzeichnis: \(error)")
//         }
//     }
//    
//    func deleteRealmDatabase() {
//        let fileManager = FileManager.default
//
//        // Pfad zum Dokumentenverzeichnis abrufen
//        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
//            print("Dokumentenverzeichnis nicht gefunden.")
//            return
//        }
//
//        // Erstellen eines Arrays mit den zu löschenden Dateinamen
//        let realmFiles = [
//            "default.realm",
//            "default.realm.management",
//            "default.realm.lock",
//            "default.realm.note"
//        ]
//
//        // Durchlaufen und Löschen der Dateien
//        for fileName in realmFiles {
//            let fileURL = documentsDirectory.appendingPathComponent(fileName)
//            
//            do {
//                if fileManager.fileExists(atPath: fileURL.path) {
//                    try fileManager.removeItem(at: fileURL)
//                    print("Datei \(fileName) erfolgreich gelöscht.")
//                } else {
//                    print("Datei \(fileName) existiert nicht.")
//                }
//            } catch {
//                print("Fehler beim Löschen der Datei \(fileName): \(error.localizedDescription)")
//            }
//        }
//    }

    
}

#Preview {
    StartStopView()
}
