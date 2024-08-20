//
//  testmotionAI.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 18.08.24.
//

import Foundation
import CoreMotion

class MotionDataRecorder: ObservableObject {

    private var motionManager: CMMotionManager
    private var dataBuffer: [[String: Any]] = []
    private let duration: TimeInterval = 10.0
    private let frequency: Double = 60.0
    private let jsonFilename = "motion_data.json"
    private let discordWebhookURL = "https://discord.com/api/webhooks/1223418868467499199/UOAUGjmezHHkJNbKp0yRfX7M4Bu9Fk5gjYmFy_e-pydLym1lLWwg0blPEN12RZ5ETadi" // Setzen Sie hier Ihre Webhook-URL ein

    init() {
        self.motionManager = CMMotionManager()
        self.motionManager.accelerometerUpdateInterval = 1.0 / frequency
    }

    func startRecording(label: String) {
        dataBuffer.removeAll()
        var startTime: TimeInterval?

        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { [weak self] (data, error) in
            guard let self = self else { return }
            guard let data = data else { return }

            if startTime == nil {
                startTime = data.timestamp
            }

            let currentTime = data.timestamp - (startTime ?? 0)
            let entry: [String: Any] = [
                "time": currentTime,
                "x": data.acceleration.x,
                "y": data.acceleration.y,
                "z": data.acceleration.z
            ]

            self.dataBuffer.append(entry)

            if currentTime >= self.duration {
                self.motionManager.stopAccelerometerUpdates()
                self.saveData(label: label)
            }
        }
    }

    private func saveData(label: String) {
        let newEntry: [String: Any] = [
            "data": dataBuffer,
            "label": label
        ]

        var jsonArray: [[String: Any]] = []
        var fileExisted = false

        if let fileURL = getFileURL() {
            // Check if the file already exists
            if let existingData = try? Data(contentsOf: fileURL),
               let existingArray = try? JSONSerialization.jsonObject(with: existingData, options: []) as? [[String: Any]] {
                jsonArray = existingArray
                fileExisted = true
            }

            // Append new entry
            jsonArray.append(newEntry)

            // Save the updated JSON array to file
            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted) {
                do {
                    try jsonData.write(to: fileURL)
                    if fileExisted {
                        print("Existing file extended and data saved to \(fileURL.path)")
                    } else {
                        print("New file created and data saved to \(fileURL.path)")
                    }
                    sendFileToDiscord(fileURL: fileURL)
                } catch {
                    print("Failed to save data: \(error)")
                }
            }
        }
    }

    private func getFileURL() -> URL? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(jsonFilename)
    }

    private func sendFileToDiscord(fileURL: URL) {
        guard let discordURL = URL(string: discordWebhookURL) else { return }
        var request = URLRequest(url: discordURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let fileData = try Data(contentsOf: fileURL)
            let json: [String: Any] = [
                "content": "Here is the JSON file:",
                "file": fileData.base64EncodedString()
            ]
            let jsonData = try JSONSerialization.data(withJSONObject: json)

            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error posting to Discord: \(error)")
                    return
                }
                print("Data posted to Discord successfully")
            }
            task.resume()

        } catch {
            print("Failed to read file data: \(error)")
        }
    }
}
