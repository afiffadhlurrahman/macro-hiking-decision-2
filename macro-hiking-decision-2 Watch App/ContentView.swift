//
//  ContentView.swift
//  macro-hiking-decision-2 Watch App
//
//  Created by Muhammad Afif Fadhlurrahman on 07/10/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var healthManager = WatchHealthManager()
    @State private var isMonitoringActive = false
    @State private var selectedTab = "OnMonitoring"

    var body: some View {
        NavigationStack {
            VStack {
                Text("Health Monitoring")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()

                Button("Start Monitoring") {
                    isMonitoringActive = true
                    selectedTab = "OnMonitoring"
                }
                .padding()
                .buttonStyle(.bordered)

                .navigationDestination(isPresented: $isMonitoringActive) {
                    WatchMonitoringView(
                        healthManager: healthManager,
                        isMonitoringActive: $isMonitoringActive,
                        selectedTab: $selectedTab)
                }
            }
        }
        .background(Color.blue.opacity(0.5))
    }
}

struct WatchMonitoringView: View {
    @ObservedObject var healthManager: WatchHealthManager
    @Binding var isMonitoringActive: Bool
    @Binding var selectedTab: String
    @State private var showAlert = false

    @State private var countdown = 3
    @State private var isCountingDown = false

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab pertama untuk menghentikan monitoring
            VStack {
                Button(action: {
                    showAlert = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 80, height: 80)
                        Image(systemName: "stop.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .buttonStyle(.plain)
                .alert(
                    "Are you sure want to stop monitoring?",
                    isPresented: $showAlert
                ) {
                    Button("Stop", role: .destructive) {
                        healthManager.stopMonitoring()
                        isMonitoringActive = false
                    }
                }
            }
            .tabItem {
                Label("Stop", systemImage: "stop.circle")
            }
            .tag("StopMonitoring")

            // Tab pertama untuk menampilkan data monitoring
            VStack(spacing: 2) {
                if isCountingDown {
                    Text("Starting in \(countdown)...")
                        .font(.body)
                        .padding()

                } else {
                    Text("Monitoring Data")
                        .font(.headline)
                        .padding()

                    ScrollView {
                        ZStack {
                            if let heartRate = healthManager.latestHeartRate,
                                let heartRateTime = healthManager.latestHeartRateTime
                            {
                                Text("HR: \(heartRate, specifier: "%.0f") bpm")
                                    .foregroundStyle(Color.red)
                                Text("Time_HR: \(heartRateTime, style: .time)")

                            } else {
                                Text("No HR data.")
                            }
                            
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 160, height: 80)
                                .foregroundStyle(Color.white.opacity(0.2))
                        }


                        ZStack{
                            if let oxygenSaturation = healthManager.latestOxygenSaturation,
                                let oxygenSaturationTime = healthManager.latestOxygenSaturationTime
                            {
                                Text("SPO2: \(oxygenSaturation * 100, specifier: "%.0f")%")
                                Text("Time_SPO2: \(oxygenSaturationTime, style: .time)")
                            } else {
                                Text("No SPO2 data.")
                            }
                            
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 160, height: 80)
                                .foregroundStyle(Color.white.opacity(0.2))
                        }

                        ZStack{
                            if let hrv = healthManager.latestHeartRateVariability,
                                let hrvTime = healthManager.latestHeartRateVariabilityTime
                            {
                                Text("HRV: \(hrv, specifier: "%.2f") ms")
                                Text("Time_HRV: \(hrvTime, style: .time)")
                            } else {
                                Text("No HRV data.")
                            }
                            
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 160, height: 80)
                                .foregroundStyle(Color.white.opacity(0.2))
                        }

                        ZStack{
                            if let altitude = healthManager.latestAltitude,
                                let altitudeTime = healthManager.latestAltitudeTime
                            {
                                Text("Alt: \(altitude, specifier: "%.2f") meters")
                                Text("Time: \(altitudeTime, style: .time)")
                            } else {
                                Text("No Alt data.")
                            }
                            
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 160, height: 80)
                                .foregroundStyle(Color.white.opacity(0.2))
                        }
                    }
                }
            }
            .tabItem {
                Label("Main Event", systemImage: "waveform.path.ecg")
            }
            .tag("OnMonitoring")
        }
        .background(Color.blue.opacity(0.2))
        .onAppear {
            startCountdown()
        }
        .tabViewStyle(PageTabViewStyle())
        .navigationBarBackButtonHidden(true)
    }

    private func startCountdown() {
        countdown = 3
        isCountingDown = true
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            countdown -= 1
            if countdown <= 0 {
                timer.invalidate()
                isCountingDown = false
                startMonitoring()
            }
        }
    }

    // Fungsi untuk memulai monitoring setelah hitungan mundur selesai
    private func startMonitoring() {
        healthManager.startMonitoring()
    }
}

struct DataComponentView {

}

#Preview {
    ContentView()
}
