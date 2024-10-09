//
//  ContentView.swift
//  macro-hiking-decision-2
//
//  Created by Muhammad Afif Fadhlurrahman on 07/10/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var healthManager = iOSHealthManager()
    @State private var showShareSheet = false
    @State private var csvURL: URL?

    var body: some View {
        VStack {
            Text("HealthKit Data Export")
                .font(.headline)
                .padding()

            Button("Add Sample Data") {
                // Menambahkan data sampel untuk tujuan demonstrasi
                healthManager.addHealthData(heartRate: 75.0, oxygenSaturation: 0.98, heartRateVariability: 50.0, altitude: 100.0)
            }
            .padding()

            Button("Export to CSV") {
                if let url = healthManager.exportToCSV() {
                    csvURL = url
                    showShareSheet = true
                    print("CSV file ready to share: \(url)")
                } else {
                    print("Failed to create CSV file.")
                }
            }
            .padding()
            .sheet(isPresented: $showShareSheet) {
                if let csvURL = csvURL {
                    ShareSheet(activityItems: [csvURL])
                }
            }
        }
    }
}

// Helper untuk menampilkan Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ContentView()
}
