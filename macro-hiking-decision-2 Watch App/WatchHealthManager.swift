//
//  WatchHealthManager.swift
//  macro-hiking-decision-2 Watch App
//
//  Created by Muhammad Afif Fadhlurrahman on 07/10/24.
//

import HealthKit
import CoreMotion
import Foundation

class WatchHealthManager: ObservableObject {
    let healthStore = HKHealthStore()
    let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    let oxygenSaturationType = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!
    let heartRateVariabilityType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
    
    @Published var latestHeartRate: Double? // Untuk menyimpan heart rate terbaru
    @Published var latestHeartRateTime: Date? // Untuk menyimpan waktu heart rate terdeteksi
    @Published var latestOxygenSaturation: Double? // Untuk menyimpan oxygen saturation terbaru
    @Published var latestOxygenSaturationTime: Date? // Untuk menyimpan waktu oxygen saturation terdeteksi
    @Published var latestHeartRateVariability: Double?
    @Published var latestHeartRateVariabilityTime: Date?
    @Published var latestAltitude: Double?
    @Published var latestAltitudeTime: Date?
    
    var heartRateTimer: Timer?
    var oxygenSaturationTimer: Timer?
    var heartRateVariabilityTimer: Timer?
    var altitudeTimer: Timer?
    
    var altimeter = CMAltimeter()
    
    init() {
        requestAuthorization()
    }
    
    // Meminta izin akses ke HealthKit
    func requestAuthorization() {
        let typesToShare: Set = [heartRateType, oxygenSaturationType, heartRateVariabilityType]
        let typesToRead: Set = [heartRateType, oxygenSaturationType, heartRateVariabilityType]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            DispatchQueue.main.async {
                if !success {
                    print("Authorization failed: \(String(describing: error))")
                } else {
                    print("Authorization succeeded!")
                }
            }
        }
    }
    
    // Memulai monitoring heart rate dan oxygen saturation
    func startMonitoring() {
        // Mengambil heart rate setiap 60 detik
        heartRateTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            self.fetchLatestHeartRateSample()
        }
        
        // Mengambil oxygen saturation setiap 60 detik
        oxygenSaturationTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            self.fetchLatestOxygenSaturationSample()
        }
        
        heartRateVariabilityTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            self.fetchLatestHeartRateVariabilitySample()
        }
        
        altitudeTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            self.detectAltitudeUsingCoreMotion()
        }
        
        print("Monitoring started.")
    }
    
    // Menghentikan monitoring
    func stopMonitoring() {
        heartRateTimer?.invalidate()
        oxygenSaturationTimer?.invalidate()
        heartRateVariabilityTimer?.invalidate()
        altitudeTimer?.invalidate()
        
        heartRateTimer = nil
        oxygenSaturationTimer = nil
        heartRateVariabilityTimer = nil
        altitudeTimer = nil
        
        altimeter.stopRelativeAltitudeUpdates()
        
        print("Monitoring stopped.")
    }
    
    // Mengambil satu data heart rate terbaru
    private func fetchLatestHeartRateSample() {
        let heartRateQuery = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { query, samples, error in
            guard let samples = samples as? [HKQuantitySample], let sample = samples.first else {
                print("No heart rate sample available")
                return
            }
            let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            self.latestHeartRate = heartRate
            self.latestHeartRateTime = sample.endDate
            print("Latest Heart Rate: \(heartRate) bpm at \(sample.endDate)")
            
            self.saveHeartRateData(heartRate: heartRate)
        }
        healthStore.execute(heartRateQuery)
    }
    
    // Mengambil satu data oxygen saturation terbaru
    private func fetchLatestOxygenSaturationSample() {
        let oxygenSaturationQuery = HKSampleQuery(sampleType: oxygenSaturationType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { query, samples, error in
            guard let samples = samples as? [HKQuantitySample], let sample = samples.first else {
                print("No oxygen saturation sample available")
                return
            }
            let oxygenSaturation = sample.quantity.doubleValue(for: HKUnit.percent())
            self.latestOxygenSaturation = oxygenSaturation
            self.latestOxygenSaturationTime = sample.endDate
            
            print("Latest Oxygen Saturation: \(oxygenSaturation * 100)% at \(sample.endDate)")
            self.saveOxygenSaturationData(oxygenSaturation: oxygenSaturation)
        }
        healthStore.execute(oxygenSaturationQuery)
    }
    
    // Mengambil satu data Heart Rate Variability terbaru
    private func fetchLatestHeartRateVariabilitySample() {
        let hrvQuery = HKSampleQuery(sampleType: heartRateVariabilityType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { query, samples, error in
            guard let samples = samples as? [HKQuantitySample], let sample = samples.first else {
                print("No heart rate variability sample available")
                return
            }
            let hrv = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
            self.latestHeartRateVariability = hrv
            self.latestHeartRateVariabilityTime = sample.endDate
            
            print("Latest HRV: \(hrv) ms at \(sample.endDate)")
            self.saveHeartRateVariabilityData(hrv: hrv)
        }
        healthStore.execute(hrvQuery)
    }
    
    // Mengambil data altitude menggunakan Core Motion
    private func detectAltitudeUsingCoreMotion() {
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) { [weak self] data, error in
                guard let self = self else { return }
                if let altitudeData = data {
                    let altitude = altitudeData.relativeAltitude.doubleValue // Mengambil ketinggian dalam meter
                    self.latestAltitude = altitude
                    self.latestAltitudeTime = Date()
                    
                    print("Detected Altitude: \(altitude) meters")
                    self.saveAltitudeData(altitude: altitude)
                } else if let error = error {
                    print("Error detecting altitude: \(error.localizedDescription)")
                }
            }
        } else {
            print("Altitude detection is not available on this device.")
        }
    }
    
    // Menyimpan heart rate ke HealthKit
    func saveHeartRateData(heartRate: Double) {
        let heartRateQuantity = HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: heartRate)
        let heartRateSample = HKQuantitySample(type: heartRateType, quantity: heartRateQuantity, start: Date(), end: Date())
        
        healthStore.save(heartRateSample) { (success, error) in
            if success {
                print("Successfully saved heart rate data.")
            } else {
                print("Error saving heart rate data: \(String(describing: error))")
            }
        }
    }
    
    // Menyimpan oxygen saturation ke HealthKit
    func saveOxygenSaturationData(oxygenSaturation: Double) {
        let oxygenSaturationQuantity = HKQuantity(unit: HKUnit.percent(), doubleValue: oxygenSaturation)
        let oxygenSaturationSample = HKQuantitySample(type: oxygenSaturationType, quantity: oxygenSaturationQuantity, start: Date(), end: Date())
        
        healthStore.save(oxygenSaturationSample) { (success, error) in
            if success {
                print("Successfully saved oxygen saturation data.")
            } else {
                print("Error saving oxygen saturation data: \(String(describing: error))")
            }
        }
    }
    
    // Menyimpan Heart Rate Variability ke HealthKit
    func saveHeartRateVariabilityData(hrv: Double) {
        let hrvQuantity = HKQuantity(unit: HKUnit.secondUnit(with: .milli), doubleValue: hrv)
        let hrvSample = HKQuantitySample(type: heartRateVariabilityType, quantity: hrvQuantity, start: Date(), end: Date())
        
        healthStore.save(hrvSample) { (success, error) in
            DispatchQueue.main.async {
                if success {
                    print("Successfully saved heart rate variability data.")
                } else {
                    print("Error saving heart rate variability data: \(String(describing: error))")
                }
            }
        }
    }
    
    // Simpan data Altitude ke dalam aplikasi (misalnya, SwiftData atau lokal)
    private func saveAltitudeData(altitude: Double) {
        // Implementasi penyimpanan di sini, misalnya menggunakan SwiftData atau lokal
        print("Saving altitude data: \(altitude) meters")
        // Anda dapat menambahkan fungsi penyimpanan sesuai dengan kebutuhan aplikasi
    }
}
