//
//  NotificationManager.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 27.01.2026.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isGranted: Bool = false
    
    // --- 1. ŽÁDOST O POVOLENÍ ---
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            DispatchQueue.main.async {
                self.isGranted = granted
                if granted {
                    print("✅ Notifikace povoleny uživatelem")
                    self.scheduleDailyNotifications()
                } else {
                    print("❌ Notifikace zamítnuty: \(String(describing: error))")
                }
            }
        }
    }
    
    // --- 2. PLÁNOVÁNÍ PRAVIDELNÝCH NOTIFIKACÍ (SHOP + QUESTS) ---
    func scheduleDailyNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_shop", "daily_quests"])
        
        // A) SCÉNÁŘ 1: Ranní Shop Reset (08:00)
        let shopContent = UNMutableNotificationContent()
        shopContent.title = "Obchod byl obnoven! 🎒"
        shopContent.body = "Tajemný obchodník má nové zboží. Podívej se, co nabízí!"
        shopContent.sound = .default
        
        var shopDate = DateComponents()
        shopDate.hour = 8
        shopDate.minute = 0
        let shopTrigger = UNCalendarNotificationTrigger(dateMatching: shopDate, repeats: true)
        let shopRequest = UNNotificationRequest(identifier: "daily_shop", content: shopContent, trigger: shopTrigger)
        
        // B) SCÉNÁŘ 2: Večerní připomínka (19:00)
        let questContent = UNMutableNotificationContent()
        questContent.title = "Nezapomeň na úkoly! ⚔️"
        questContent.body = "Tvé denní questy brzy vyprší."
        questContent.sound = .default
        
        var questDate = DateComponents()
        questDate.hour = 19
        questDate.minute = 0
        let questTrigger = UNCalendarNotificationTrigger(dateMatching: questDate, repeats: true)
        let questRequest = UNNotificationRequest(identifier: "daily_quests", content: questContent, trigger: questTrigger)
        
        UNUserNotificationCenter.current().add(shopRequest)
        UNUserNotificationCenter.current().add(questRequest)
    }
    
    // --- 3. PLÁNOVÁNÍ NEAKTIVITY (Zavolá se při odchodu na pozadí) ---
    func scheduleInactivityReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Dlouho jsi tu nebyl, Hrdino! 🛡️"
        content.body = "Tvé království tě potřebuje. Vrať se do boje!"
        content.sound = .default
        
        // ⚠️ PRO TESTOVÁNÍ: 10. 
        // Až to otestuješ, změň 10 na 172800 (což je 48 hodin).
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        
        let request = UNNotificationRequest(identifier: "inactivity_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        print("💤 Naplánována notifikace neaktivity (za 10 sekund).")
    }
    
    // Zruší neaktivitu (Zavolá se, když uživatel otevře appku)
    func cancelInactivityReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["inactivity_reminder"])
        print("👋 Uživatel je zpět, ruším notifikaci neaktivity.")
    }
    
    // Zruší vše (když to vypne v nastavení)
    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑 Všechny notifikace zrušeny.")
    }
}
