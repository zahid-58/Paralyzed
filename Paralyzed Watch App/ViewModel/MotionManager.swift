//
//  MotionManager.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 13.06.24.
//

import Foundation
import CoreMotion

class MotionManager: ObservableObject {
    private var motionActivityManager: CMMotionActivityManager?

    @Published var isStationary: Bool = false

    init() {
        self.motionActivityManager = CMMotionActivityManager()

        if CMMotionActivityManager.isActivityAvailable() {
            self.motionActivityManager?.startActivityUpdates(to: OperationQueue.main) { activity in
                DispatchQueue.main.async {
                    if let activity = activity {
                        self.isStationary = activity.stationary
                    }
                }
            }
        }
    }

    func stop() {
        motionActivityManager?.stopActivityUpdates()
        motionActivityManager = nil
        print("MotionManger STOPPED")
    }
}
