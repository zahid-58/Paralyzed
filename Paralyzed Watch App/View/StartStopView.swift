//
//  ContentView.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 28.01.24.
//

import SwiftUI

struct StartStopView: View {
    @StateObject private var healthManager = HealthManager()
    @State private var isActivated: Bool = false
    @State private var showImpactNotificationView = false // Zustandsvariable für die Anzeige der ImpactNotificationView
    
    @State private var motionActive: Bool = false
    
    @StateObject private var motionManager = MotionManager()
    
    var body: some View {
        NavigationView{
            VStack {
                if !isActivated{
                    Button("Tap to activate") {
                        isActivated = true
                        healthManager.requestAuthorization()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .fontWeight(.bold)
                    .padding()
                    Text("Status:") + Text(" is deactivated").foregroundColor(.red)
                }else{
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
                
                //Hier ist unser Algo im Moment zum detektieren
                Text("Herzfrequenz: \(healthManager.heartRate, specifier: "%.0f") BPM")
                    .onChange(of: healthManager.averageHeartRate) { newValue in
                        if newValue > Config.loadHeartrateLimit() { // Setze den Schwellenwert nach Bedarf
                            
                            healthManager.stopMonitoringAndTimer()
                            healthManager.isMonitoring = false
                            healthManager.averageHeartRate = 0
                            
                            motionManager.startMonitoring(for: 10)
                            motionActive = true

                        }
                    }
                
                if motionActive {
                    Text("Bewegungsdaten werden gescannt...")
                        .onChange(of: motionManager.motionNotDetected) { newValue in
                            if newValue == 1{
                                motionManager.motionNotDetected = 0
                                isActivated = false
                                showImpactNotificationView = true
                                motionManager.stopMonitoring()
                                
                                motionActive = false
                            }
                            
                            if newValue == 2{
                                print("bewgung erkannt deshalb geht es weiter")
                                healthManager.requestAuthorization()
                                
                                motionActive = false
                            }
                            

                        }
                    
                }

                // Füge hier zusätzliche UI-Elemente hinzu, um weitere Daten anzuzeigen
                
            }
            
        }
        .navigationBarBackButtonHidden()
        .fullScreenCover(isPresented: $showImpactNotificationView, content: {
            ImpactNotificationView(showImpactNotificationView: $showImpactNotificationView)
                    })
//        .sheet(isPresented: $showImpactNotificationView){
//            ImpactNotificationView()
//        }
    }
}

#Preview {
    StartStopView()
}
