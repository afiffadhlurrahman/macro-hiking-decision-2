//
//  ContentView.swift
//  macro-hiking-decision-2 Watch App
//
//  Created by Muhammad Afif Fadhlurrahman on 07/10/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var healthManager = WatchHealthManager()
    @State private var isMonitoringActive = false // State untuk navigasi
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Health Monitoring")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button("Start Monitoring") {
                    healthManager.startMonitoring()
                    isMonitoringActive = true
                }
                .padding()
                .buttonStyle(.borderedProminent)
                .navigationDestination(isPresented: $isMonitoringActive) {
                    WatchMonitoringView(healthManager: healthManager)
                }
            }
        }
    }
}

struct WatchMonitoringView: View {  // Hanya untuk Watch
    @ObservedObject var healthManager: WatchHealthManager
    var body: some View {
        ScrollView{
            VStack(spacing: 2) {
                Text("Monitoring Data")
                    .font(.headline)
                    .padding()
                
                if let heartRate = healthManager.latestHeartRate, let heartRateTime = healthManager.latestHeartRateTime {
                    Text("HR: \(heartRate, specifier: "%.0f") bpm")
                    Text("Time: \(heartRateTime, style: .time)")
                } else {
                    Text("No HR data.")
                }
                
                if let oxygenSaturation = healthManager.latestOxygenSaturation, let oxygenSaturationTime = healthManager.latestOxygenSaturationTime {
                    Text("SPO2: \(oxygenSaturation * 100, specifier: "%.0f")%")
                    Text("Time: \(oxygenSaturationTime, style: .time)")
                } else {
                    Text("No SPO2 data.")
                }
                
                if let hrv = healthManager.latestHeartRateVariability {
                    Text("HRV: \(hrv, specifier: "%.2f") ms")
                } else {
                    Text("No HRV data.")
                }
                
                if let altitude = healthManager.latestAltitude {
                    Text("Alt: \(altitude, specifier: "%.2f") meters")
                } else {
                    Text("No Alt data.")
                }
                
                Button("Stop Monitoring") {
                    healthManager.stopMonitoring()
                }
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
