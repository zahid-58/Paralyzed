//
//  ParalyzedApp.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 28.01.24.
//

import SwiftUI
//@main
//struct Paralyzed_Watch_AppApp: App {
//    @StateObject var vibrationAndAlarmManager = VibrationAndAlarmManager()
//
//    var body: some Scene {
//        WindowGroup {
//            //let _ = print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path)
//            SessionPagingView()
//                .environmentObject(vibrationAndAlarmManager)
//            // Durch Hinzufügen von .environmentObject(vibrationAndAlarmManager) zur SessionPagingView machst du vibrationAndAlarmManager und seine Daten in dieser View und allen darin enthaltenen Child-Views verfügbar. Dies bedeutet, dass jede View, die Zugriff auf die Daten oder Funktionen des VibrationAndAlarmManager benötigt, diese über @EnvironmentObject erhalten kann.
//        }
//    }
//
//}

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

