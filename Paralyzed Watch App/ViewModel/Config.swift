//
//  config.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 12.08.24.
//

import Foundation

class Config{
    static var heartRateLimit: Double = 60
    static var settingsToggle: Int = 1
    
    static func saveHeartrateLimit(limit: Double) {
        UserDefaults.standard.set(limit, forKey: "heartrateLimit")
    }
    
    static func loadHeartrateLimit() -> Double {
        
        if UserDefaults.standard.double(forKey: "heartrateLimit") != 0.0{
            return UserDefaults.standard.double(forKey: "heartrateLimit")
        }else{
            return heartRateLimit
        }
    }
    
    static func saveSettingsToggle(active: Int) {
        UserDefaults.standard.set(active, forKey: "settingActive")
    }
    
    static func loadSettingsToggle() -> Int {
        
        if UserDefaults.standard.integer(forKey: "settingActive") != 0{
            return UserDefaults.standard.integer(forKey: "settingActive")
        }else{
            return settingsToggle
        }
    }
}
