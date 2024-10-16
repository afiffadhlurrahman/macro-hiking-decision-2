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
                        if let heartRate = healthManager.latestHeartRate,
                           let heartRateTime = healthManager.latestHeartRateTime {
                            HealthDataView(
                                title: "HR",
                                value: String(format: "%.0f bpm", heartRate),
                                time: heartRateTime.formatted(.dateTime.hour().minute().second()),
                                color: .red
                            )
                        } else {
                            Text("No HR data.")
                        }
                        
                        if let oxygenSaturation = healthManager.latestOxygenSaturation,
                           let oxygenSaturationTime = healthManager.latestOxygenSaturationTime {
                            HealthDataView(
                                title: "SPO2",
                                value: String(format: "%.0f%%", oxygenSaturation * 100),
                                time: oxygenSaturationTime.formatted(.dateTime.hour().minute().second()),
                                color: .blue
                            )
                        } else {
                            Text("No SPO2 data.")
                        }
                        
                        if let hrv = healthManager.latestHeartRateVariability,
                           let hrvTime = healthManager.latestHeartRateVariabilityTime {
                            HealthDataView(
                                title: "HRV",
                                value: String(format: "%.2f ms", hrv),
                                time: hrvTime.formatted(.dateTime.hour().minute().second()),
                                color: .green
                            )
                        } else {
                            Text("No HRV data.")
                        }
                        
                        if let altitude = healthManager.latestAltitude,
                           let altitudeTime = healthManager.latestAltitudeTime {
                            HealthDataView(
                                title: "Alt",
                                value: String(format: "%.2f meters", altitude),
                                time: altitudeTime.formatted(.dateTime.hour().minute().second()),
                                color: .orange
                            )
                        } else {
                            Text("No Alt data.")
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

struct HealthDataView: View {
    var title: String
    var value: String
    var time: String
    var color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 160, height: 80)
                .foregroundStyle(color.opacity(0.2))
            
            VStack {
                Text("\(title): \(value)")
                    .foregroundStyle(color)
                Text("Time: \(time)")
            }
        }
    }
}

#Preview {
    ContentView()
}
