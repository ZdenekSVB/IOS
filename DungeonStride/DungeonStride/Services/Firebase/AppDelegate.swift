//
//  AppDelegate.swift
//  DungeonStride
//

import UIKit
import Firebase
import FirebaseMessaging
import GoogleSignIn
import UserNotifications // NUTNÝ IMPORT

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        setupFirebaseMessagingForDebug()
        
        // Nastavení delegáta pro notifikace (aby fungovaly v popředí)
        UNUserNotificationCenter.current().delegate = self
        
        print("✅ AppDelegate configured")
        return true
    }
    
    private func setupFirebaseMessagingForDebug() {
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Zde by byl kód pro APNs token
    }
}

// Rozšíření pro zpracování notifikací přímo v App
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Notifikace přijde, když je aplikace ZAPNUTÁ
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // .banner zobrazí notifikaci nahoře, .sound přehraje zvuk
        completionHandler([.banner, .sound, .badge])
    }
    
    // Uživatel KLIKL na notifikaci
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("🔔 Kliknuto na notifikaci")
        completionHandler()
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // Firebase messaging delegate
    }
}
