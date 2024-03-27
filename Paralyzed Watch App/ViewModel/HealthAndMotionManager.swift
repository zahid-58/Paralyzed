//
//  HealthAndMotionManager.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 19.02.24.
//

import Foundation
import HealthKit
import CoreMotion

class HealthAndMotionManager: ObservableObject {
    private var healthStore = HKHealthStore()
    private let motionManager = CMMotionManager()
    private var heartRateQuery: HKQuery? // Speichert die aktive Herzfrequenzabfrage
    
    @Published var heartRate: Double = 0
    @Published var acceleration: CMAcceleration = CMAcceleration(x: 0, y: 0, z: 0)
    @Published var isHeartRateMonitoringActive: Bool = false
    
//    init() {
//        startMotionUpdates()
//    }
    
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
                self?.startHeartRateMonitoring()
            }
        }
    }
    
    // Startet die Aufzeichnung der Herzfrequenz
    func startHeartRateMonitoring() {
        print("Is heart rate active? " , isHeartRateMonitoringActive)
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
    
    // Startet die Aufzeichnung der Bewegungsdaten
    func startMotionUpdates() {
        print("Activating motion updates...")
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0 // 60 Hz
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
                guard let motion = motion else { return }
                DispatchQueue.main.async {
                    self?.acceleration = motion.userAcceleration
                }
            }
        }
    }
    
    // Stopt die Herzfrequenzüberwachung sowie Bewegungsdaten
    func stopMonitoring() {
        print("Deactivating heart monitoring and motion updates...")
        motionManager.stopDeviceMotionUpdates()
        if let query = heartRateQuery {
            healthStore.stop(query) // Beendet die Herzfrequenzabfrage
            // Setzen Sie isHeartRateMonitoringActive auf false, wenn die Überwachung endet
            self.isHeartRateMonitoringActive = false
            heartRateQuery = nil
            print("Is heart rate active? " , isHeartRateMonitoringActive)
        }
        print("Is heart rate active? " , isHeartRateMonitoringActive)
    }
}
