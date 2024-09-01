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
    @State private var audioActive: Bool = false
    
    
    var body: some View {
        let timerManager = TimerManager(healthManager: healthManager, audioManager: audioManager)
        NavigationView {
            VStack {
                if !isActivated {
                    Button("Tap to activate") {
                        isActivated = true

                        //uploadRealmToDiscord()

                        timerManager.startCycle()
                        audioActive = true
                        
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
                        motionActive = false
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
                            healthManager.isMonitoring = false
                            audioActive = false
                            motionManager.startMonitoring(for: 10)
                            motionActive = true
                        }
                    }
                
                if audioActive {
                    Text("AI Audio Detection...")
                        .onReceive(NotificationCenter.default.publisher(for: .predictionDidChange)) { _ in
                        
                            if TimerManager.prediction == "fast" {
                                audioActive = false
                                healthManager.stopMonitoringHeartRate()
                                motionManager.startMonitoring(for: 10)
                                motionActive = true
                            }
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
    
    
}

#Preview {
    StartStopView()
}
