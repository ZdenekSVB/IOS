//
//  AppDelegate.swift
//  DungeonStride
//

import UIKit
import Firebase
import FirebaseMessaging
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        setupFirebaseMessagingForDebug()
        print("✅ AppDelegate configured - Firebase Messaging ready for debug")
        return true
    }
    
    private func setupFirebaseMessagingForDebug() {
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        
        #if DEBUG
        print("🔧 DEBUG: Firebase Messaging enabled for debugging")
        #endif
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        #if DEBUG
        let tokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("🔧 DEBUG: APNs token received: \(tokenString)")
        #endif
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        #if DEBUG
        print("🔧 DEBUG: FCM Token: \(fcmToken ?? "nil")")
        
        if let token = fcmToken {
            UserDefaults.standard.set(token, forKey: "debug_fcm_token")
        }
        #endif
    }
}
