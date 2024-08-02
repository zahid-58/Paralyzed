//
//  RespiratoryManager.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 20.07.24.
//

import Foundation
import HealthKit

class RespiratoryManager: ObservableObject {
    private let healthStore = HKHealthStore()
    private var observerQuery: HKObserverQuery?
    private var anchoredQuery: HKAnchoredObjectQuery?

    init() {
        requestAuthorization()
    }

    private func requestAuthorization() {
        print("is in Atem auth request")
        let respiratoryRateType = HKObjectType.quantityType(forIdentifier: .respiratoryRate)!

        healthStore.requestAuthorization(toShare: nil, read: [respiratoryRateType]) { (success, error) in
            if success {
                print("Authorization granted")
            } else {
                print("Authorization failed: \(String(describing: error?.localizedDescription))")
            }
        }
    }

    func startRespiratoryMonitoring() {
        print("is in start Atem")
        let respiratoryRateType = HKObjectType.quantityType(forIdentifier: .respiratoryRate)!

        observerQuery = HKObserverQuery(sampleType: respiratoryRateType, predicate: nil) { [weak self] query, completionHandler, error in
            guard error == nil else {
                print("ObserverQuery failed: \(String(describing: error?.localizedDescription))")
                return
            }

            self?.fetchLatestRespiratoryRate()
            completionHandler()
        }

        if let observerQuery = observerQuery {
            healthStore.execute(observerQuery)
        }
    }

    private func fetchLatestRespiratoryRate() {
        print("is in fetchLatest Atem")
        let respiratoryRateType = HKObjectType.quantityType(forIdentifier: .respiratoryRate)!
        anchoredQuery = HKAnchoredObjectQuery(type: respiratoryRateType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
            guard let samples = samplesOrNil as? [HKQuantitySample], errorOrNil == nil else {
                print("AnchoredObjectQuery failed: \(String(describing: errorOrNil?.localizedDescription))")
                return
            }

            for sample in samples {
                print("is in Atem for Schleife")
                let rate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                let date = sample.startDate
                print("Respiratory rate: \(rate) breaths per minute at \(date)")
            }
        }

        if let anchoredQuery = anchoredQuery {
            healthStore.execute(anchoredQuery)
        }
    }

    func stopMonitoring() {
        if let observerQuery = observerQuery {
            healthStore.stop(observerQuery)
            print("ObserverQuery stopped.")
        }

        if let anchoredQuery = anchoredQuery {
            healthStore.stop(anchoredQuery)
            print("AnchoredObjectQuery stopped.")
        }
    }
}
