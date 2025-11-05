//
//  AppDelegate.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//

import UIKit
import Firebase
import FirebaseMessaging
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Povol Messaging pro debug, ale bez notifikací
        setupFirebaseMessagingForDebug()
        
        print("✅ AppDelegate configured - Firebase Messaging ready for debug")
        return true
    }
    
    private func setupFirebaseMessagingForDebug() {
        // Messaging je povolené, ale nebudeme žádat o notifikace
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        
        #if DEBUG
        print("🔧 DEBUG: Firebase Messaging enabled for debugging")
        print("🔧 DEBUG: FCM Token will be available for testing")
        #endif
    }
    
    func application(_ app: UIApplication,
                         open url: URL,
                         options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
            // Google Sign-In callback handler
            return GIDSignIn.sharedInstance.handle(url)
        }
        
    
    func application(_ application: UIApplication,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Toto voláme pouze pokud budeme chtít notifikace
        // Messaging.messaging().apnsToken = deviceToken
        #if DEBUG
        let tokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("🔧 DEBUG: APNs token received: \(tokenString)")
        #endif
    }
}

// MARK: - MessagingDelegate pro debug
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // Toto se zavolá když Messaging získá FCM token
        // Můžeme ho logovat pro debugování
        #if DEBUG
        print("🔧 DEBUG: FCM Token: \(fcmToken ?? "nil")")
        
        // Můžeme token uložit pro pozdější použití
        if let token = fcmToken {
            UserDefaults.standard.set(token, forKey: "debug_fcm_token")
            print("🔧 DEBUG: FCM Token saved to UserDefaults")
        }
        #endif
    }
}
