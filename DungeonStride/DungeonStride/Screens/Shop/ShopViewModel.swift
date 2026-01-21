//
//  ShopViewModel.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 19.12.2025.
//

import SwiftUI
import FirebaseFirestore

class ShopViewModel: ObservableObject {
    @Published var slots: [ShopSlot] = []
    @Published var timeToNextReset: String = "--:--:--"
    @Published var masterItems: [String: AItem] = [:] // Cache definic itemů
    @Published var user: User?
    
    private var db = Firestore.firestore()
    private var userId: String?
    private var timer: Timer?
    
    // Deinit pro zastavení časovače, když odejdeš ze screeny
    deinit {
        timer?.invalidate()
    }
    
    // 1. Hlavní načítací funkce
    func fetchData(userId: String) {
        self.userId = userId
        
        // A. Stáhneme všechny itemy (abychom věděli, co můžeme prodávat)
        db.collection("items").getDocuments { [weak self] snapshot, _ in
            guard let self = self, let docs = snapshot?.documents else { return }
            
            var itemsDict: [String: AItem] = [:]
            for doc in docs {
                if let item = try? doc.data(as: AItem.self), let id = item.id {
                    itemsDict[id] = item
                }
            }
            self.masterItems = itemsDict
            
            // B. Teď začneme poslouchat Usera (jeho goldy a shop)
            self.listenToUser()
        }
    }
    
    private func listenToUser() {
        guard let uid = userId else { return }
        
        db.collection("users").document(uid).addSnapshotListener { [weak self] snapshot, _ in
            guard let self = self, let user = try? snapshot?.data(as: User.self) else { return }
            
            DispatchQueue.main.async {
                self.user = user
                self.slots = user.shopData.slots
                
                // C. Kontrola času: Uběhlo 24 hodin?
                // 86400 sekund = 24 hodin
                let timeSinceReset = Date().timeIntervalSince(user.shopData.lastResetDate)
                
                if timeSinceReset > 86400 {
                    print("⏰ Čas na reset obchodu! Generuji nové zboží...")
                    self.generateNewShop(user: user)
                } else {
                    // Spustíme odpočet
                    self.startTimer(lastReset: user.shopData.lastResetDate)
                }
            }
        }
    }
    
    // 2. Generování nového zboží (Random)
    private func generateNewShop(user: User) {
        guard !masterItems.isEmpty, let uid = userId else { return }
        
        // Vyfiltrujeme jen prodejné věci (mají cenu > 0)
        let availableItems = Array(masterItems.values).filter { ($0.baseStats.sellPrice ?? 0) > 0 }
        
        // Vybereme 6 náhodných
        let randomSelection = availableItems.shuffled().prefix(6)
        
        var newSlots: [ShopSlot] = []
        
        for item in randomSelection {
            // Cena v obchodě je 4x vyšší než prodejní cena
            // (nebo si vymysli vlastní vzorec)
            let basePrice = item.baseStats.sellPrice ?? 10
            let buyPrice = basePrice * 2
            
            newSlots.append(ShopSlot(
                itemId: item.id ?? "",
                price: buyPrice,
                isPurchased: false
            ))
        }
        
        // Vytvoříme data pro update
        // Musíme to namapovat ručně na Dictionary, protože updateData to vyžaduje
        let slotsData = newSlots.map { [
            "id": $0.id,
            "itemId": $0.itemId,
            "price": $0.price,
            "isPurchased": $0.isPurchased
        ] }
        
        // Uložíme do Firestore (pouze shopData, nepřepisujeme celého Usera)
        db.collection("users").document(uid).updateData([
            "shopData.lastResetDate": Timestamp(date: Date()),
            "shopData.slots": slotsData
        ])
    }
    
    // 3. Nákup itemu
    func buyItem(slot: ShopSlot) {
        guard let uid = userId, let user = user else { return }
        
        // Kontroly
        if slot.isPurchased { return }
        if user.coins < slot.price {
            print("❌ Nedostatek peněz!")
            return
        }
        
        // Použijeme Batch Write (Atomická operace: Všechno nebo nic)
        let batch = db.batch()
        let userRef = db.collection("users").document(uid)
        
        // A. Najdeme a aktualizujeme slot na "isPurchased = true"
        var updatedSlots = user.shopData.slots
        if let index = updatedSlots.firstIndex(where: { $0.id == slot.id }) {
            updatedSlots[index].isPurchased = true
        }
        
        let slotsData = updatedSlots.map { [
            "id": $0.id,
            "itemId": $0.itemId,
            "price": $0.price,
            "isPurchased": $0.isPurchased
        ] }
        
        // B. Odečteme peníze a aktualizujeme shop v Userovi
        batch.updateData([
            "coins": user.coins - slot.price,
            "shopData.slots": slotsData
        ], forDocument: userRef)
        
        // C. Přidáme item do Inventáře (Subkolekce)
        let newInventoryRef = userRef.collection("inventory").document() // Auto ID
        batch.setData([
            "itemId": slot.itemId, // Tady musí být to ID z Master items (např. "knights_sword")
            "quantity": 1
        ], forDocument: newInventoryRef)
        
        // Odeslání do DB
        batch.commit { error in
            if let error = error {
                print("❌ Chyba při nákupu: \(error.localizedDescription)")
            } else {
                print("✅ Nákup úspěšný! Item přidán do inventáře.")
            }
        }
    }
    
    // 4. Odpočet času
    private func startTimer(lastReset: Date) {
        timer?.invalidate()
        
        // Aktualizujeme UI každou sekundu
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let nextReset = lastReset.addingTimeInterval(86400) // + 24h
            let remaining = nextReset.timeIntervalSince(Date())
            
            if remaining <= 0 {
                self.timeToNextReset = "Obnovuji..."
                // Pokud jsi na screeně a čas vyprší, vyvoláme refresh
                if let u = self.user { self.generateNewShop(user: u) }
            } else {
                let hours = Int(remaining) / 3600
                let minutes = (Int(remaining) % 3600) / 60
                let seconds = Int(remaining) % 60
                self.timeToNextReset = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            }
        }
    }
}
