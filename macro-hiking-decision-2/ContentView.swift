//
//  ContentView.swift
//  macro-hiking-decision-2
//
//  Created by Muhammad Afif Fadhlurrahman on 07/10/24.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @StateObject var healthManager = iOSHealthManager()  // Using the iOSHealthManager for iOS
    @State private var isMonitoringActive = false
    @State private var selectedTab = "OnMonitoring"

    var body: some View {
        NavigationStack {
            VStack {
                Text("Health Monitoring - iOS")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button(action: {
                    if !healthManager.isMonitoring {
                        healthManager.startMonitoring()
                        isMonitoringActive = true
                        selectedTab = "OnMonitoring"
                    }
                }) {
                    Text("Start Monitoring")
                        .frame(minWidth: 300, minHeight: 80)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
                .disabled(healthManager.isMonitoring) // Disable button when monitoring is active
                .navigationDestination(isPresented: $isMonitoringActive) {
                    iOSMonitoringView(healthManager: healthManager, isMonitoringActive: $isMonitoringActive)
                }
                .navigationDestination(isPresented: $healthManager.shouldNavigateToMonitoringView) {
                    iOSMonitoringView(healthManager: healthManager, isMonitoringActive: $isMonitoringActive)
                }
            }
            //.background(Color.blue.opacity(0.5))
        }
        //.ignoresSafeArea()
        //.foregroundStyle(Color.red.opacity(1))
        .background(Color.blue)
        
    }
}

struct iOSMonitoringView: View {
    @ObservedObject var healthManager: iOSHealthManager  // Correctly observed object
    @Binding var isMonitoringActive: Bool
    @State private var showAlert = false
    @State private var countdown = 3
    @State private var isCountingDown = false

    var body: some View {
        VStack(spacing: 2) {
            if isCountingDown {
                Text("Starting in \(countdown)...")
                    .font(.body)
                    .padding()
            } else {
                Spacer()
                    .frame(height: 200)
                Text("Monitoring Data - iOS")
                    .font(.headline)
                    .padding()

                ScrollView {
                    // Accessing the latestHeartRate and latestHeartRateTime properly
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

                    // Accessing the latestOxygenSaturation and latestOxygenSaturationTime properly
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

                    // Accessing the latestHeartRateVariability and latestHeartRateVariabilityTime properly
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

                    // Accessing the latestAltitude and latestAltitudeTime properly
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

                Button(action: {
                    showAlert = true
                }) {
                    Text("Stop Monitoring")
                        .frame(minWidth: 300, minHeight: 80)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
                .alert("Are you sure want to stop monitoring?", isPresented: $showAlert) {
                    Button("Stop", role: .destructive) {
                        healthManager.stopMonitoring()
                        isMonitoringActive = false
                    }
                }
            }
        }
        .onAppear {
            startCountdown()
        }
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
                .frame(width: 200, height: 80)
                .foregroundStyle(color.opacity(0.1))

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
