//
//  SettingsView.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 14.02.24.
//

import SwiftUI

struct SettingsView: View {
    @State private var activeToggle: Int = 3 // 1 für Vibration, 2 für Alarm, 3 für Vibration und Alarm
    @EnvironmentObject var vibrationAndAlarmManager: VibrationAndAlarmManager
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("At least one setting must be activated")) {
                    Toggle(isOn: Binding<Bool>(
                        get: { self.vibrationAndAlarmManager.activeToggle == 1 },
                        set: { newValue in
                            if newValue { self.vibrationAndAlarmManager.activeToggle = 1 }
                        }
                    )) {
                        Text("Vibration")
                    }
                    
                    Toggle(isOn: Binding<Bool>(
                        get: { self.vibrationAndAlarmManager.activeToggle == 2 },
                        set: { newValue in
                            if newValue { self.vibrationAndAlarmManager.activeToggle = 2 }
                        }
                    )) {
                        Text("Alarm")
                    }
                    
                    Toggle(isOn: Binding<Bool>(
                        get: { self.vibrationAndAlarmManager.activeToggle == 3 },
                        set: { newValue in
                            if newValue { self.vibrationAndAlarmManager.activeToggle = 3 }
                        }
                    )) {
                        Text("Vibration and Alarm")
                    }
                }
            }.navigationTitle("Settings")
                .listStyle(.carousel)
            //            .navigationTitle("Settings")
            //            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(VibrationAndAlarmManager())
    }
}
