//
//  iOSHealthManager.swift
//  macro-hiking-decision-2
//
//  Created by Muhammad Afif Fadhlurrahman on 07/10/24.
//

import HealthKit
import SwiftUI

class iOSHealthManager: ObservableObject {
    @Published var healthData: [HealthDataModel] = []
    
    // Fungsi untuk menambahkan data kesehatan
    func addHealthData(heartRate: Double, oxygenSaturation: Double, heartRateVariability: Double, altitude: Double) {
        let newData = HealthDataModel(heartRate: heartRate, oxygenSaturation: oxygenSaturation, heartRateVariability: heartRateVariability, altitude: altitude, timestamp: Date())
        healthData.append(newData)
        print("Data added: \(newData)")
    }
    
    // Fungsi untuk mengekspor data ke CSV
    func exportToCSV() -> URL? {
        if healthData.isEmpty {
            print("No health data to export.")
            return nil
        }
        return CSVExporter.exportHealthDataToCSV(data: healthData)
    }
}
