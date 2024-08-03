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
    @EnvironmentObject var vibrationAndAlarmManager: VibrationAndAlarmManager
    
    //---neu
    @ObservedObject var managerProvider = ManagerProvider.shared
    
    var body: some View {
        NavigationView{
            VStack {
                if !isActivated{
                    Button("Tap to activate") {
                        isActivated = true
                        healthManager.requestAuthorization()
                        healthManager.startHeartRateMonitoring()
                        
                        //---neu
                        //managerProvider.motionManager.startMonitoring(for: 10.0)
                        
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
                        managerProvider.motionManager.stopMonitoring()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .fontWeight(.bold)
                    .padding()
                    Text("Status:") + Text(" is activated").foregroundColor(.green)
                }
                
                //Hier ist unser Algo im Moment zum detektieren
                Text("Herzfrequenz: \(healthManager.heartRate, specifier: "%.0f") BPM")
                    .onChange(of: healthManager.heartRate) { newValue in
                        if newValue > 120 { // Setze den Schwellenwert nach Bedarf
                            
                            healthManager.stopMonitoringAndTimer()
                            healthManager.isMonitoring = false
                            isActivated = false
                            
                            
                            showImpactNotificationView = true

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
