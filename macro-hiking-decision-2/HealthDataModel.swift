//
//  HealthDataModel.swift
//  macro-hiking-decision-2
//
//  Created by Muhammad Afif Fadhlurrahman on 09/10/24.
//

import Foundation

struct HealthDataModel: Identifiable {
    let id = UUID()
    let heartRate: Double
    let oxygenSaturation: Double
    let heartRateVariability: Double
    let altitude: Double
    let timestamp: Date
}
