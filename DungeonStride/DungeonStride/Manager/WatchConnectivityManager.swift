//
//  WatchConnectivityManager.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 19.01.2026.
//


//
//  WatchConnectivityManager.swift
//  DungeonStride
//

import Foundation
import WatchConnectivity
import Combine

class WatchConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var receivedWorkoutData: [String: Any]?
    
    override private init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func sendWorkoutToPhone(data: [String: Any]) {
        guard WCSession.default.activationState == .activated else { return }
        
        // Použijeme transferUserInfo pro spolehlivé doručení na pozadí
        WCSession.default.transferUserInfo(data)
    }
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation logic if needed
    }
    
    // Tyto metody jsou vyžadovány jen pro iOS, na watchOS mohou být prázdné
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate() // Reactivate for switching watches
    }
    #endif
    
    // Příjem dat (z hodinek na telefon nebo opačně)
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            self.receivedWorkoutData = userInfo
            
            // Tady můžeš vyvolat notifikaci, že dorazila data
            NotificationCenter.default.post(name: NSNotification.Name("WorkoutReceived"), object: nil, userInfo: userInfo)
        }
    }
}
