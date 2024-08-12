//
//  MotionManager.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 13.06.24.
//

import CoreMotion
import Foundation

class MotionManager: ObservableObject{
    let motionManager = CMMotionManager()
    var timer: Timer?
    @Published var motionNotDetected = 0 // Variable, um festzustellen, ob Bewegung erkannt wurde
    var xValues: [Double] = []
    var yValues: [Double] = []
    var zValues: [Double] = []

    // Funktion zum Starten der Bewegungsüberwachung
    func startMonitoring(for duration: TimeInterval) {
        guard motionManager.isAccelerometerAvailable else {
            print("Beschleunigungsmesser nicht verfügbar.")
            return
        }
        motionNotDetected = 0
        xValues.removeAll()
        yValues.removeAll()
        zValues.removeAll()

        motionManager.accelerometerUpdateInterval = 1.0 / 2.0 // Daten werden 2 Mal pro Sekunde aktualisiert
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            guard let data = data else {
                print("Fehler beim Abrufen von Accelerometer-Daten: \(error?.localizedDescription ?? "Unbekannter Fehler")")
                return
            }
            
            print("Aktuelle Beschleunigungsdaten: x = \(data.acceleration.x), y = \(data.acceleration.y), z = \(data.acceleration.z)")
            
            // Speichere die x, y, z Werte in den entsprechenden Listen
            self?.xValues.append(data.acceleration.x)
            self?.yValues.append(data.acceleration.y)
            self?.zValues.append(data.acceleration.z)

        }

        // Timer einrichten, um die Überwachung zu stoppen
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.stopMonitoring()
            self.calculateAndPrintAverageDifferences()
            if self.motionNotDetected == 1 {
                print("Keine Bewegung erkannt.")
            }
            
            if self.motionNotDetected == 2 {
                print("Bewegung erkannt.")
            }
            
        }
    }

    // Funktion zum Stoppen der Überwachung
    func stopMonitoring() {
        motionManager.stopAccelerometerUpdates()
        timer?.invalidate()
        timer = nil
        motionNotDetected = 0
        
        print("MOTION STOPPED")
    }

    func calculateAndPrintAverageDifferences() {
        printAverageDifference(for: xValues, axis: "X")
        printAverageDifference(for: yValues, axis: "Y")
        printAverageDifference(for: zValues, axis: "Z")
    }

    func printAverageDifference(for values: [Double], axis: String) {
        guard let firstValue = values.first else { return }
        
        // Liste für die Speicherung der absoluten Differenzen
        var differences: [Double] = []

        // Starte die Schleife beim zweiten Wert (index 1)
        for value in values.dropFirst() {
            let difference = abs(firstValue - value)
            differences.append(difference)
        }
        
        // Summiere alle Differenzen
        let sumOfDifferences = differences.reduce(0.0, +)

        // Anzahl der Differenzen
        let numberOfDifferences = Double(differences.count)

        // Berechne den Durchschnitt der Differenzen
        // Prüfe, ob die Anzahl der Differenzen größer als 0 ist, um Division durch Null zu vermeiden
        let averageDifference = numberOfDifferences > 0 ? sumOfDifferences / numberOfDifferences : 0.0
        
        if averageDifference < 0.2 {
            motionNotDetected = 1
        }else{
            motionNotDetected = 2
        }
        
        print("Durchschnittliche absolute Differenz für Achse \(axis): \(String(format: "%.4f", averageDifference))")
    }
}
