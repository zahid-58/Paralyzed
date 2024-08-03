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
    
    func requestAuthorization() {
        print("Requesting authrorization...")
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        
        let typesToRead: Set = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ]
        
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { [weak self] success, _ in
            if success {
               // zum Testen:
                self?.startStopTimer()
                print("requestttt")
            }
        }
    }
    
    // Startet die Aufzeichnung der Herzfrequenz
    func startHeartRateMonitoring() {
        print("Activating heart monitoring...")
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        
        // Setzen Sie isHeartRateMonitoringActive auf true, wenn die Überwachung startet
        self.isHeartRateMonitoringActive = true
        
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { [weak self] _, sampleObjects, _, _, _ in
            
            guard let samples = sampleObjects as? [HKQuantitySample] else { return }
            let latestSample = samples.last?.quantity.doubleValue(for: HKUnit(from: "count/min"))
            DispatchQueue.main.async {
                self?.heartRate = latestSample ?? 0
            }
        }
        
        query.updateHandler = { [weak self] _, sampleObjects, _, _, _ in
            guard let samples = sampleObjects as? [HKQuantitySample] else { return }
            let latestSample = samples.last?.quantity.doubleValue(for: HKUnit(from: "count/min"))
            DispatchQueue.main.async {
                self?.heartRate = latestSample ?? 0
            }
        }
        
        healthStore.execute(query)
        heartRateQuery = query // Speichert die Referenz auf die Abfrage
    }
    
    func startStopTimer(){
        print("in startstoptimer func drin")
        
        // Starte den Timer, um alle Sekunden die neueste Herzfrequenz abzurufen
        DispatchQueue.main.async {
            //timer?.invalidate() // Stoppe den vorhandenen Timer, falls aktiv
            self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
                self?.toggleMonitoring()
                print("timer iterierung")
            }
        }
    }
    
    
    func toggleMonitoring(){
        if isMonitoring {
            stopMonitoringInTimer()
            print("Herzfrequenz stoppt")
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
