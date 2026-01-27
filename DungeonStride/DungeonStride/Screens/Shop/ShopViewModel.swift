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
    @Published var masterItems: [String: AItem] = [:]
    @Published var user: User?
    @Published var isLoading: Bool = true
    
    private var db = Firestore.firestore()
    private var userId: String?
    private var timer: Timer?
    
    deinit { timer?.invalidate() }
    
    func fetchData(userId: String) {
        self.userId = userId
        self.isLoading = true
        
        db.collection("items").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            guard let docs = snapshot?.documents, !docs.isEmpty else {
                self.listenToUser()
                return
            }
            
            var itemsDict: [String: AItem] = [:]
            for doc in docs {
                if var item = try? doc.data(as: AItem.self) {
                    if item.id == nil { item.id = doc.documentID }
                    if let id = item.id { itemsDict[id] = item }
                }
            }
            self.masterItems = itemsDict
            self.listenToUser()
        }
    }
    
    private func listenToUser() {
        guard let uid = userId else { return }
        
        db.collection("users").document(uid).addSnapshotListener { [weak self] snapshot, error in
            guard let self = self, let user = try? snapshot?.data(as: User.self) else {
                self?.isLoading = false
                return
            }
            
            DispatchQueue.main.async {
                self.user = user
                self.slots = user.shopData.slots
                
                let timeSinceReset = Date().timeIntervalSince(user.shopData.lastResetDate)
                
                if timeSinceReset > 86400 || self.slots.isEmpty {
                    self.generateNewShop(user: user)
                } else {
                    self.startTimer(lastReset: user.shopData.lastResetDate)
                    self.isLoading = false
                }
            }
        }
    }
    
    func rerollShop() {
        guard let user = user, let uid = userId else { return }
        let rerollCost = 50
        
        if user.coins < rerollCost { return }
        
        self.isLoading = true
        db.collection("users").document(uid).updateData([
            "coins": FieldValue.increment(Int64(-rerollCost))
        ])
        generateNewShop(user: user, force: true)
    }
    
    private func generateNewShop(user: User, force: Bool = false) {
        guard !masterItems.isEmpty, let uid = userId else {
            self.isLoading = false
            return
        }
        
        let allItems = Array(masterItems.values)
        let count = min(allItems.count, 6)
        let randomSelection = allItems.shuffled().prefix(count)
        
        var newSlots: [ShopSlot] = []
        for item in randomSelection {
            let basePrice = (item.baseStats.sellPrice ?? 0) > 0 ? item.baseStats.sellPrice! : 10
            let buyPrice = basePrice * 4
            if let iId = item.id {
                newSlots.append(ShopSlot(itemId: iId, price: buyPrice, isPurchased: false))
            }
        }
        
        let slotsData = newSlots.map { [
            "id": $0.id, "itemId": $0.itemId, "price": $0.price, "isPurchased": $0.isPurchased
        ] }
        
        var updateData: [String: Any] = ["shopData.slots": slotsData]
        if !force {
            updateData["shopData.lastResetDate"] = Timestamp(date: Date())
        }
        
        db.collection("users").document(uid).updateData(updateData) { _ in
            self.isLoading = false
        }
    }
    
    func buyItem(slot: ShopSlot) {
        guard let uid = userId, let user = user else { return }
        if slot.isPurchased || user.coins < slot.price { return }
        
        let batch = db.batch()
        let userRef = db.collection("users").document(uid)
        
        // 1. Update Shop
        var updatedSlots = user.shopData.slots
        if let index = updatedSlots.firstIndex(where: { $0.id == slot.id }) {
            updatedSlots[index].isPurchased = true
        }
        let slotsData = updatedSlots.map { ["id": $0.id, "itemId": $0.itemId, "price": $0.price, "isPurchased": $0.isPurchased] }
        
        batch.updateData(["coins": user.coins - slot.price, "shopData.slots": slotsData], forDocument: userRef)
        
        // 2. Add to Inventory (kontrola existence by byla lepší, ale v batchi to nejde číst - pro zjednodušení děláme blind write nebo předpokládáme že backend logika to pořeší, tady vytváříme nový)
        // V předchozím kroku jsme dělali čtení, ale tady to zjednodušíme aby to nepadalo na async chybách
        let inventoryRef = userRef.collection("inventory")
        
        // Zkusíme najít dokument se stejným itemId (toto vyžaduje čtení před zápisem, což v batchi nejde přímo)
        // Takže uděláme čtení mimo batch:
        inventoryRef.whereField("itemId", isEqualTo: slot.itemId).getDocuments { [weak self] snapshot, _ in
            guard let self = self else { return }
            
            // Teď vytvoříme batch (protože jsme uvnitř callbacku)
            let innerBatch = self.db.batch()
            
            // Update peněz a slotů (znovu, protože jsme v novém scope)
            innerBatch.updateData(["coins": user.coins - slot.price, "shopData.slots": slotsData], forDocument: userRef)
            
            if let existingDoc = snapshot?.documents.first {
                let currentQty = existingDoc.data()["quantity"] as? Int ?? 1
                innerBatch.updateData(["quantity": currentQty + 1], forDocument: existingDoc.reference)
            } else {
                let newDoc = inventoryRef.document()
                innerBatch.setData(["itemId": slot.itemId, "quantity": 1], forDocument: newDoc)
            }
            
            innerBatch.commit()
        }
    }
    
    private func startTimer(lastReset: Date) {
        timer?.invalidate()
        updateTimerLabel(lastReset: lastReset)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimerLabel(lastReset: lastReset)
        }
    }
    
    private func updateTimerLabel(lastReset: Date) {
        let remaining = lastReset.addingTimeInterval(86400).timeIntervalSince(Date())
        if remaining <= 0 {
            self.timeToNextReset = "00:00:00"
            if let u = self.user, !self.isLoading { self.generateNewShop(user: u) }
        } else {
            let h = Int(remaining) / 3600
            let m = (Int(remaining) % 3600) / 60
            let s = Int(remaining) % 60
            self.timeToNextReset = String(format: "%02d:%02d:%02d", h, m, s)
        }
    }
}
