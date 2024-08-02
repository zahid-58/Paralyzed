//
//  ContentView.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 28.01.24.
//

import SwiftUI

struct StartStopView: View {
    @StateObject private var healthAndMotionManager = HealthAndMotionManager()
    @State private var isActivated: Bool = false
    @State private var showImpactNotificationView = false // Zustandsvariable für die Anzeige der ImpactNotificationView
    @EnvironmentObject var vibrationAndAlarmManager: VibrationAndAlarmManager
    @StateObject private var motionManager = MotionManager()
    @StateObject private var respiratoryManager = RespiratoryManager()
    
    var body: some View {
        NavigationView{
            VStack {
                if !isActivated{
                    Button("Tap to activate") {
                        isActivated = true
                        healthAndMotionManager.requestAuthorization()
                        //healthAndMotionManager.startHeartRateMonitoring()
                        healthAndMotionManager.startMotionUpdates()
                        
                        respiratoryManager.startRespiratoryMonitoring()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .fontWeight(.bold)
                    .padding()
                    Text("Status:") + Text(" is deactivated").foregroundColor(.red)
                }else{
                    Button("Tap to deactivate") {
                        isActivated = false
                        healthAndMotionManager.stopMonitoringAndTimer()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .fontWeight(.bold)
                    .padding()
                    Text("Status:") + Text(" is activated").foregroundColor(.green)
                }
                
                //Hier ist unser Algo im Moment zum detektieren
                Text("Herzfrequenz: \(healthAndMotionManager.heartRate, specifier: "%.0f") BPM")
                    .onChange(of: healthAndMotionManager.heartRate) { newValue in
                        if newValue > 120 && motionManager.isStationary { // Setze den Schwellenwert nach Bedarf
                            
                            healthAndMotionManager.stopMonitoringAndTimer()
                            healthAndMotionManager.isMonitoring = false
                            isActivated = false
                            motionManager.stop()
                            
                            respiratoryManager.stopMonitoring()
                            
                            showImpactNotificationView = true

                        }
                    }
                Text("Beschleunigung X: \(String(format: "%.2f", healthAndMotionManager.acceleration.x))")
                Text("Beschleunigung Y: \(String(format: "%.2f", healthAndMotionManager.acceleration.y))")
                Text("Beschleunigung Z: \(String(format: "%.2f", healthAndMotionManager.acceleration.z))")

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
