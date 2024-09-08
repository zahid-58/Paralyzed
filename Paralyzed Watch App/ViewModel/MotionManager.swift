//
//  MotionManager.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 13.06.24.
//

import CoreMotion
import RealmSwift

enum MotionDetectionStatus {
    case noMovement
    case movementDetected
    case undetermined
}

class MotionManager: ObservableObject{
    var motionManager = CMMotionManager()
    var timer: Timer?
    @Published var motionStatus: MotionDetectionStatus = .undetermined
    var xValues: [Double] = []
    var yValues: [Double] = []
    var zValues: [Double] = []
    
    @ObservedResults(MotionData.self) var motiondb
    
    let movementThreshold = 0.09 // zum Testen, davor stand 0.1
    

    // Funktion zum Starten der Bewegungsüberwachung
    func startMonitoring(for duration: TimeInterval) {
        guard motionManager.isAccelerometerAvailable else {
            print("Beschleunigungsmesser nicht verfügbar.")
            return
        }
        motionStatus = .undetermined
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
            
            let motionRow = MotionData()
            
            motionRow.x = data.acceleration.x
            motionRow.y = data.acceleration.y
            motionRow.z = data.acceleration.z
            motionRow.timestamp = Date()
            motionRow.scanid = HealthManager.scanid
            motionRow.detected = false
            
            self?.$motiondb.append(motionRow)
            

        }

        // Timer einrichten, um die Überwachung zu stoppen
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.stopMonitoring()
            self.calculateAndPrintAverageDifferences()
            
            switch self.motionStatus {
            case .noMovement:
                print("Keine Bewegung erkannt.")
                
                // Alle relevanten Datensätze in der MotionData-Tabelle auf detected = true setzen
                if let realm = try? Realm() {
                    try? realm.write {
                        let motionResults = realm.objects(MotionData.self).filter("scanid == %@", HealthManager.scanid!)
                        motionResults.setValue(true, forKey: "detected")
                    }
                }
                
                // Alle relevanten Datensätze in der HeartRateData-Tabelle auf detected = true setzen
                if let realm = try? Realm() {
                    try? realm.write {
                        let heartRateResults = realm.objects(HeartRateData.self).filter("scanid == %@", HealthManager.scanid!)
                        heartRateResults.setValue(true, forKey: "detected")
                    }
                }
            case .movementDetected:
                print("Bewegung erkannt, es geht weiter")
            case .undetermined:
                print("Bewegungsstatus unbestimmt.")
            }
            
        }
    }

    // Funktion zum Stoppen der Überwachung
    func stopMonitoring() {
        motionManager.stopAccelerometerUpdates()
        timer?.invalidate()
        timer = nil
        motionStatus = .undetermined
        
        print("Motion stopped")
    }

    func calculateAndPrintAverageDifferences() {
        let statusX = printAverageDifference(for: xValues, axis: "X")
        let statusY = printAverageDifference(for: yValues, axis: "Y")
        let statusZ = printAverageDifference(for: zValues, axis: "Z")
        
        motionStatus = (statusX == .movementDetected || statusY == .movementDetected || statusZ == .movementDetected) ? .movementDetected : .noMovement
    }

    func printAverageDifference(for values: [Double], axis: String) -> MotionDetectionStatus {
        guard let firstValue = values.first else { return .undetermined }
        
        var differences: [Double] = []
        
        for value in values.dropFirst() {
            let difference = abs(firstValue - value)
            differences.append(difference)
        }
        
        let sumOfDifferences = differences.reduce(0.0, +)
        let numberOfDifferences = Double(differences.count)
        let averageDifference = numberOfDifferences > 0 ? sumOfDifferences / numberOfDifferences : 0.0
        
        print("Durchschnittliche absolute Differenz für Achse %{public}@ : %{public}.4f", axis, averageDifference)
        
        return averageDifference < movementThreshold ? .noMovement : .movementDetected      
    }

}
