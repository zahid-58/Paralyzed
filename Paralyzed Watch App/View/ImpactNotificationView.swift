//
//  ImpactNotificationView.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 24.02.24.
//

import SwiftUI

struct ImpactNotificationView: View {
    @State private var animate = false
    @Environment(\.presentationMode) var presentationMode
    @Binding var showImpactNotificationView: Bool
    @EnvironmentObject var vibrationAndAlarmManager: VibrationAndAlarmManager
    
        
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Paralysis detected!")
                    .font(.headline)
                    .padding(10)
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 42))
                    .foregroundColor(.red)
                    .scaleEffect(animate ? 1.2 : 1.0) // Skaliere das Symbol größer und kleiner, um einen Bounce-Effekt zu simulieren
                    .padding(.bottom, 10)
                
                    // Beim Erscheinen des ImpactNotificationView, wird hier je nach Bedingung entschieden, ob Vibration, Alarm oder beides aktiviert werden im Falle einer Auslösung
                    .onAppear{
                        
                        if vibrationAndAlarmManager.activeToggle == 1{
                            vibrationAndAlarmManager.startAction(type: .vibration)
                        }
                        
                        if vibrationAndAlarmManager.activeToggle == 2{
                            vibrationAndAlarmManager.startAction(type: .alarm)
                        }
                        
                        if vibrationAndAlarmManager.activeToggle == 3{
                            vibrationAndAlarmManager.startAction(type: .both)
                        }
                        
                        
                        withAnimation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)){
                            animate = true
                        }
                    }
                    .padding(.bottom, 10)
                
                Button("Done") {
                                    presentationMode.wrappedValue.dismiss()
                                    vibrationAndAlarmManager.doneButtonClicked = true
                                    
                                }
                                .foregroundColor(.white)
                                .padding()
                                .cornerRadius(10)
                                .padding(10)
                                
            }
            .navigationBarHidden(true) // Versteckt die komplette NavigationBar, einschließlich des "X" Buttons
        }
    }
}

//#Preview {
//    ImpactNotificationView(showImpactNotificationView: .constant(true), vibrationAndAlarmManager: VibrationAndAlarmManager())
//}
