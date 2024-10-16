//
//  iOSHealthManager.swift
//  macro-hiking-decision-2
//
//  Created by Muhammad Afif Fadhlurrahman on 07/10/24.
//

import HealthKit
import Foundation
import WatchConnectivity

class iOSHealthManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published var isMonitoring: Bool = false
    @Published var shouldNavigateToMonitoringView: Bool = false
    
    @Published var latestHeartRate: Double?
    @Published var latestHeartRateTime: Date?
    @Published var latestOxygenSaturation: Double?
    @Published var latestOxygenSaturationTime: Date?
    @Published var latestHeartRateVariability: Double?
    @Published var latestHeartRateVariabilityTime: Date?
    @Published var latestAltitude: Double?
    @Published var latestAltitudeTime: Date?
    
    private var session: WCSession

    override init() {
        session = WCSession.default
        super.init()
        session.delegate = self
        if WCSession.isSupported() {
            session.activate() // Activate session
        }
    }
    
    // WCSessionDelegate methods
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let startMonitoring = message["isMonitoring"] as? Bool {
            DispatchQueue.main.async {
                if self.isMonitoring != startMonitoring {
                    if startMonitoring {
                        self.startMonitoring()
                        self.shouldNavigateToMonitoringView = true
                    } else {
                        self.stopMonitoring()
                        self.shouldNavigateToMonitoringView = false
                    }
                    
                    // Send acknowledgment back to Watch
                    replyHandler(["received": true])
                }
            }
            print("Masuk IF sini!")
        } else {
            print("Unknown message received: \(message)")
            replyHandler(["received": false])
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated successfully.")
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            print("Watch is reachable.")
        } else {
            print("Watch is not reachable.")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        // Handle if necessary
    }

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    
    // Send monitoring status to Watch, only if the states are different
    func sendMonitoringStatusToWatch(isMonitoring: Bool) {
        if session.isReachable && self.isMonitoring != isMonitoring {
            let message = ["isMonitoring": isMonitoring]
            session.sendMessage(message, replyHandler: nil) { error in
                print("Error sending message: \(error.localizedDescription)")
            }
        } else {
            print("Watch is not reachable or states are already the same.")
        }
    }
    
    // Start monitoring
    func startMonitoring() {
        if !isMonitoring {
            isMonitoring = true
            sendMonitoringStatusToWatch(isMonitoring: true)
            print("Send monitoring start status to Watch.")
            // Start Health monitoring on iOS...
        }
    }

    // Stop monitoring
    func stopMonitoring() {
        if isMonitoring {
            isMonitoring = false
            sendMonitoringStatusToWatch(isMonitoring: false)
            print("Send monitoring stop status to Watch.")
            // Stop Health monitoring on iOS...
        }
    }
}

