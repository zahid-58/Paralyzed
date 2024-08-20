//
//  SettingsView.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 14.02.24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var vibrationAndAlarmManager: VibrationAndAlarmManager
    @State private var selectedHeartRate: Double = Config.loadHeartrateLimit()
    @State private var confirmedHeartRate: Double = Config.loadHeartrateLimit() // Neue State-Variable

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Picker("Herzfrequenz wählen", selection: $selectedHeartRate) {
                        ForEach(40..<201, id: \.self) { rate in
                            Text("\(rate) BPM").tag(Double(rate))
                        }
                    }
                    .focusable(true)
                    .frame(height: 50) // Angepasste Höhe für bessere Sichtbarkeit
                    .frame(width: 90)
                    .labelsHidden()
                    
                    Button(action: {
                        Config.saveHeartrateLimit(limit: selectedHeartRate)
                        confirmedHeartRate = selectedHeartRate // Aktualisiere die bestätigte Herzfrequenz

                        // Haptisches Feedback geben
                        WKInterfaceDevice.current().play(.success)
                    }) {
                        Text("OK")
                            .padding()
                    }
                    .background(Capsule().fill(Color.green))
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .frame(width: 90)
                }

                HStack {
                    Text("Gewählte Herzfrequenz: \(Int(confirmedHeartRate)) BPM") // Zeigt die bestätigte Herzfrequenz an
                        .font(.headline)
                        .minimumScaleFactor(0.6) // Erlaubt dem Text, sich zu verkleinern, um in die View zu passen.
                }
                .padding(.horizontal) // Fügt horizontal etwas Padding hinzu, um nicht ganz am Rand zu sein.
                .frame(height: 15)
                .frame(width: 200)

                Divider()

                Toggle("Vibration", isOn: Binding<Bool>(
                    get: { self.vibrationAndAlarmManager.activeToggle == 1 },
                    set: { newValue in
                        if newValue {
                            self.vibrationAndAlarmManager.activeToggle = 1
                            Config.saveSettingsToggle(active: 1)
                        }
                    }
                ))

                Toggle("Alarm", isOn: Binding<Bool>(
                    get: { self.vibrationAndAlarmManager.activeToggle == 2 },
                    set: { newValue in
                        if newValue {
                            self.vibrationAndAlarmManager.activeToggle = 2
                            Config.saveSettingsToggle(active: 2)
                        }
                    }
                ))

                Toggle("Vibration und Alarm", isOn: Binding<Bool>(
                    get: { self.vibrationAndAlarmManager.activeToggle == 3 },
                    set: { newValue in
                        if newValue {
                            self.vibrationAndAlarmManager.activeToggle = 3
                            Config.saveSettingsToggle(active: 3)
                        }
                    }
                ))
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
        }
    }
}

// Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(VibrationAndAlarmManager())
    }
}
