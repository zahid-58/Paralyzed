//
//  ParalyzedApp.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 28.01.24.
//

import SwiftUI

@main
struct ParalyzedApp: App {
    // Zugriff auf die ScenePhase-Umgebung
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var vibrationAndAlarmManager = VibrationAndAlarmManager()
    
    var body: some Scene {
        WindowGroup {
            SessionPagingView().environmentObject(vibrationAndAlarmManager)
                .onChange(of: scenePhase) { newPhase in
                    switch newPhase {
                    case .active:
                        print("App ist aktiv")
                    case .inactive:
                        print("App ist inaktiv")
                    case .background:
                        print("App ist im Hintergrund")
                    @unknown default:
                        print("Ein unbekannter Status wurde erkannt")
                    }
                }
        }
    }
}

