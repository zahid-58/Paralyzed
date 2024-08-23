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
    @State private var showImpactNotificationView = false
    @State private var motionActive: Bool = false
    @StateObject private var motionManager = MotionManager()
    @StateObject private var motionDataRecorder = MotionDataRecorder()
    @AppStorage("isWelcomeScreenOver") var isWelcomeScreenOver = false
    
    var body: some View {
        NavigationView {
            VStack {
                if !isActivated {
                    Button("Tap to activate") {
                        isActivated = true
                        healthManager.requestAuthorization()
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
            }
            .navigationBarBackButtonHidden()
            .fullScreenCover(isPresented: $showImpactNotificationView) {
                ImpactNotificationView(showImpactNotificationView: $showImpactNotificationView)
            }
            .fullScreenCover(isPresented: .constant(!isWelcomeScreenOver)) {
                WelcomeView(isWelcomeScreenOver: $isWelcomeScreenOver)
                    .navigationBarHidden(true) // Verbirgt die NavigationBar in der WelcomeView
            }
        }
    }
}

#Preview {
    StartStopView()
}
