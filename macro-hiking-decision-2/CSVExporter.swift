//
//  CSVExporter.swift
//  macro-hiking-decision-2
//
//  Created by Muhammad Afif Fadhlurrahman on 09/10/24.
//

import Foundation

class CSVExporter {
    static func exportHealthDataToCSV(data: [HealthDataModel]) -> URL? {
        let fileName = "HealthData.csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        var csvText = "Heart Rate, Oxygen Saturation, HRV, Altitude, Timestamp\n"
        
        // Cek apakah data ada
        guard !data.isEmpty else {
            print("No data to export")
            return nil
        }
        
        for record in data {
            let newLine = "\(record.heartRate), \(record.oxygenSaturation), \(record.heartRateVariability), \(record.altitude), \(record.timestamp)\n"
            csvText.append(newLine)
        }
        
        do {
            // Tulis CSV ke file
            try csvText.write(to: path, atomically: true, encoding: .utf8)
            print("CSV file created at: \(path)")
            return path
        } catch {
            print("Failed to write CSV file: \(error)")
            return nil
        }
    }
}

