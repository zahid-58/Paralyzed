//
//  HealthAndMotionManager.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 19.02.24.
//

import Foundation
import HealthKit
import CoreMotion

class HealthManager: ObservableObject {
    private var healthStore = HKHealthStore()
    private var heartRateQuery: HKQuery? // Speichert die aktive Herzfrequenzabfrage
    private var timer: Timer? // Timer für regelmäßige Herzfrequenzupdates
    @Published var isMonitoring: Bool = false // Zustand der Überwachung
    
    @Published var heartRate: Double = 0
    @Published var isHeartRateMonitoringActive: Bool = false
    
    // Eigenschaft zur Speicherung der Herzfrequenzdaten
    var heartRateData: [Double] = []
    
    @Published var averageHeartRate: Double = 0
    
    func requestAuthorization() {
        print("Requesting authorization...")
        let healthStore = HKHealthStore()
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data is not available on this device.")
            return
        }
        
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate),
              let restingHeartRateType = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else {
            print("Required health data types are not available.")
            return
        }

        let typesToRead: Set<HKObjectType> = [heartRateType]
        
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { [weak self] success, error in
            if success {
                self?.startStopTimer()
                print("Authorization granted.")
            } else {
                if let error = error {
                    print("Authorization failed with error: \(error.localizedDescription)")
                } else {
                    print("Authorization failed.")
                }
            }
        }
    }
    
    // Startet die Aufzeichnung der Herzfrequenz
    func startHeartRateMonitoring() {
        print("Activating heart monitoring...")
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        
        // Daten zurücksetzen
        self.heartRate = 0
        self.heartRateData.removeAll()
        
        // Setzen Sie isHeartRateMonitoringActive auf true, wenn die Überwachung startet
        self.isHeartRateMonitoringActive = true
        
        
        
        // Leerer Block für den initialen Datenabruf
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { _, _, _, _, _ in
            // Keine Aktion benötigt beim initialen Abruf
        }
        
        // UpdateHandler wartet automatisch auf neue Ergebnisse und gibt sie dann während dem Scan aus
        query.updateHandler = { [weak self] _, sampleObjects, _, _, _ in
            guard let samples = sampleObjects as? [HKQuantitySample] else { return }
            let latestSample = samples.last?.quantity.doubleValue(for: HKUnit(from: "count/min"))
            DispatchQueue.main.async {
                self?.heartRate = latestSample ?? 0
                self?.heartRateData.append(latestSample ?? 0)
                print("Heart Rate: \(self?.heartRate ?? 0)")
            }
        }
    
        
        healthStore.execute(query)
        heartRateQuery = query // Speichert die Referenz auf die Abfrage
    }
    
    // Berechnen des Durchschnittswertes der Herzfrequenz
    func calculateAverageHeartRate() {
        let sum = heartRateData.reduce(0, +)
        averageHeartRate = sum / Double(heartRateData.count)
        print("Average Heart Rate: \(averageHeartRate)")
    }
    
    func startStopTimer(){
        print("in startstoptimer func drin")
        
        // Starte den Timer, um alle Sekunden die neueste Herzfrequenz abzurufen
        DispatchQueue.main.async {
            //timer?.invalidate() // Stoppe den vorhandenen Timer, falls aktiv
            self.timer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { [weak self] _ in
                self?.toggleMonitoring()
                print("timer iterierung")
            }
        }
    }
    
    
    func toggleMonitoring(){
        if isMonitoring {
            calculateAverageHeartRate()
            stopMonitoringInTimer()
            print("Herzfrequenz stoppt")
            
            //heartRateData.removeAll()
        } else {
            startHeartRateMonitoring()
            print("Herzfrequenz startet")
        }
        isMonitoring.toggle() // Ändere den Zustand der Überwachung
    }

    
    // Stoppt die Herzfrequenzüberwachung
    func stopMonitoringAndTimer() {
        print("Deactivating heart monitoring...")
        stopMonitoringInTimer()
        
        timer?.invalidate()
        timer = nil

    }
    
    func stopMonitoringInTimer() {
        
        if let query = heartRateQuery {
            healthStore.stop(query) // Beendet die Herzfrequenzabfrage
            // Setzen Sie isHeartRateMonitoringActive auf false, wenn die Überwachung endet
            self.isHeartRateMonitoringActive = false
            heartRateQuery = nil
            print("Is heart rate active? " , isHeartRateMonitoringActive)
        }
    }
 
    
}
