//
//  HealthManager.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 19.02.24.
//

import Foundation
import HealthKit
import CoreMotion
import RealmSwift


class HealthManager: ObservableObject {
    private var healthStore = HKHealthStore()
    private var heartRateQuery: HKQuery? // Speichert die aktive Herzfrequenzabfrage
    private var timer: Timer? // Timer für regelmäßige Herzfrequenzupdates
    @Published var isMonitoring: Bool = false // Zustand der Überwachung
    
    @Published var heartRate: Double = 0
    @Published var isHeartRateMonitoringActive: Bool = false
    
    var heartRateData: [Double] = []
    
    @Published var averageHeartRate: Double = 0
    
    @ObservedResults(HeartRateData.self) var heartRatedb
    
    static var scanid: UUID? = nil
    
    
    func requestAuthorization() {
        print("Requesting authorization...")
        let healthStore = HKHealthStore()
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data is not available on this device.")
            return
        }
        
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            print("Required health data types are not available.")
            return
        }

        let typesToRead: Set<HKObjectType> = [heartRateType]
        
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { [weak self] success, error in
            if success {
                //self?.startStopTimer()
                print("Authorization granted.")
                self?.startHeartRateMonitoring()
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
        
        HealthManager.scanid = UUID()
        
        
        
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
                
                let heartRateRow = HeartRateData()
                heartRateRow.heartrate = latestSample ?? 0
                heartRateRow.timestamp = Date()
                heartRateRow.scanid = HealthManager.scanid
                heartRateRow.detected = false
                
                self?.$heartRatedb.append(heartRateRow)
                
            }
        }
    
        
        healthStore.execute(query)
        heartRateQuery = query // Speichert die Referenz auf die Abfrage
        
        
        // Timer einrichten, um die Überwachung zu stoppen
         DispatchQueue.main.async {
             self.timer = Timer.scheduledTimer(withTimeInterval: 25, repeats: false) { [weak self] _ in
                 guard let self = self else { return }
                 self.calculateAverageHeartRate()
                 self.stopMonitoringHeartRate()
             }
         }
        
        
    }
    
    // Berechnen des Durchschnittswertes der Herzfrequenz
    func calculateAverageHeartRate() {
        let sum = heartRateData.reduce(0, +)
        averageHeartRate = sum / Double(heartRateData.count)
        print("Average Heart Rate: \(averageHeartRate)")
    }
    
    func stopMonitoringHeartRate() {
        print("Deactivating heart monitoring...")
        if let query = heartRateQuery {
            healthStore.stop(query) // Beendet die Herzfrequenzabfrage
            // Setzen Sie isHeartRateMonitoringActive auf false, wenn die Überwachung endet
            self.isHeartRateMonitoringActive = false
            heartRateQuery = nil
            print("Is heart rate active? " , isHeartRateMonitoringActive)
        }
        timer?.invalidate()
        timer = nil
    }
    
}
