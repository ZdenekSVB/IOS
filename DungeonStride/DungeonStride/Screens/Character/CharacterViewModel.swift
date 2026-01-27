//
//  CharacterViewModel.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 19.12.2025.
//

import SwiftUI
import FirebaseFirestore

class CharacterViewModel: ObservableObject {
    @Published var user: User?
    @Published var inventoryItems: [InventoryItem] = []
    @Published var masterItems: [String: AItem] = [:]
    
    @Published var showInventory: Bool = false
    @Published var selectedItemForCompare: InventoryItem?
    @Published var selectedEquippedSlot: EquipSlot?
    
    private var db = Firestore.firestore()
    private var currentUserId: String?
    
    private var userListener: ListenerRegistration?
    private var inventoryListener: ListenerRegistration?
    
    deinit { stopListening() }
    
    func fetchData(for userId: String) {
        if currentUserId == userId && user != nil { return }
        stopListening()
        self.currentUserId = userId
        
        db.collection("items").getDocuments { [weak self] snapshot, _ in
            guard let self = self, let docs = snapshot?.documents else { return }
            var itemsDict: [String: AItem] = [:]
            for doc in docs {
                if var item = try? doc.data(as: AItem.self) {
                    if item.id == nil { item.id = doc.documentID }
                    if let id = item.id { itemsDict[id] = item }
                }
            }
            DispatchQueue.main.async {
                self.masterItems = itemsDict
                self.startListeningToUser(userId: userId)
            }
        }
    }
    
    func stopListening() {
        userListener?.remove()
        inventoryListener?.remove()
        user = nil
        inventoryItems = []
        currentUserId = nil
    }
    
    private func startListeningToUser(userId: String) {
        userListener = db.collection("users").document(userId).addSnapshotListener { [weak self] snapshot, _ in
            if let updatedUser = try? snapshot?.data(as: User.self) {
                DispatchQueue.main.async {
                    self?.user = updatedUser
                    if self?.inventoryListener == nil {
                        self?.startListeningToInventory(userId: userId)
                    }
                }
            }
        }
    }
    
    private func startListeningToInventory(userId: String) {
        inventoryListener = db.collection("users").document(userId).collection("inventory").addSnapshotListener { [weak self] invSnapshot, _ in
            guard let self = self, let invDocs = invSnapshot?.documents else { return }
            
            var loadedInv: [InventoryItem] = []
            for doc in invDocs {
                if let slot = try? doc.data(as: UserInventorySlot.self),
                   let masterItem = self.masterItems[slot.itemId] {
                    loadedInv.append(InventoryItem(id: doc.documentID, item: masterItem, quantity: slot.quantity))
                }
            }
            DispatchQueue.main.async {
                self.inventoryItems = loadedInv.sorted { $0.rarityRank > $1.rarityRank }
            }
        }
    }
    
    func getEquippedItem(for slot: EquipSlot) -> AItem? {
        guard let user = user, let itemId = user.equippedIds[slot.id] else { return nil }
        return masterItems[itemId]
    }
    
    // --- LOGIKA EQUIP ---
    func equipItem(_ newItem: InventoryItem) {
        guard let userId = currentUserId, var user = user, let slot = newItem.item.computedSlot else { return }
        let slotId = slot.id
        guard let itemID = newItem.item.id else { return }
        
        let batch = db.batch()
        let userRef = db.collection("users").document(userId)
        let inventoryRef = userRef.collection("inventory")
        
        if let oldItemId = user.equippedIds[slotId], let oldItem = masterItems[oldItemId] {
            applyItemStats(user: &user, item: oldItem, isEquipping: false)
            let newInvDoc = inventoryRef.document()
            batch.setData(["itemId": oldItemId, "quantity": 1], forDocument: newInvDoc)
        }
        
        user.equippedIds[slotId] = itemID
        applyItemStats(user: &user, item: newItem.item, isEquipping: true)
        
        let itemRef = inventoryRef.document(newItem.id)
        if newItem.quantity > 1 {
            batch.updateData(["quantity": newItem.quantity - 1], forDocument: itemRef)
        } else {
            batch.deleteDocument(itemRef)
        }
        
        batch.updateData(["equippedIds": user.equippedIds, "stats": user.stats.toDictionary()], forDocument: userRef)
        batch.commit()
        self.user = user
    }
    
    // --- LOGIKA UNEQUIP ---
    func unequipItem(slot: EquipSlot) {
        guard let userId = currentUserId, var user = user,
              let oldItemId = user.equippedIds[slot.id],
              let oldItem = masterItems[oldItemId] else { return }
        
        let batch = db.batch()
        let userRef = db.collection("users").document(userId)
        
        applyItemStats(user: &user, item: oldItem, isEquipping: false)
        user.equippedIds.removeValue(forKey: slot.id)
        
        let newInvDoc = userRef.collection("inventory").document()
        batch.setData(["itemId": oldItemId, "quantity": 1], forDocument: newInvDoc)
        
        batch.updateData(["equippedIds": user.equippedIds, "stats": user.stats.toDictionary()], forDocument: userRef)
        batch.commit()
        self.user = user
    }
    
    // --- LOGIKA PRODEJE ---
    func sellItem(item: InventoryItem) {
        guard let userId = currentUserId else { return }
        let sellPrice = item.item.finalSellPrice ?? 10
        
        let batch = db.batch()
        let userRef = db.collection("users").document(userId)
        let itemRef = userRef.collection("inventory").document(item.id)
        
        // Přičíst peníze
        batch.updateData(["coins": FieldValue.increment(Int64(sellPrice))], forDocument: userRef)
        
        // Odebrat z inventáře
        if item.quantity > 1 {
            batch.updateData(["quantity": item.quantity - 1], forDocument: itemRef)
        } else {
            batch.deleteDocument(itemRef)
        }
        
        batch.commit()
        print("💰 Prodal jsi \(item.item.name) za \(sellPrice)")
    }
    
    private func applyItemStats(user: inout User, item: AItem, isEquipping: Bool) {
        let multiplier = isEquipping ? 1 : -1
        if let pAtk = item.baseStats.physicalDamage { user.stats.physicalDamage += (pAtk * multiplier) }
        if let mAtk = item.baseStats.magicDamage { user.stats.magicDamage += (mAtk * multiplier) }
        if let pDef = item.baseStats.physicalDefense { user.stats.defense += (pDef * multiplier) }
        if let hp = item.baseStats.healthBonus { user.stats.maxHP += (hp * multiplier) }
        
        user.stats.physicalDamage = max(1, user.stats.physicalDamage)
        user.stats.magicDamage = max(0, user.stats.magicDamage)
        user.stats.defense = max(0, user.stats.defense)
        user.stats.maxHP = max(10, user.stats.maxHP)
    }
    
    func upgradeStat(_ stat: String, cost: Int = 1) {
        guard let userId = currentUserId, let user = user, user.statPoints >= cost else { return }
        db.collection("users").document(userId).updateData([
            "stats.\(stat)": FieldValue.increment(Int64(1)),
            "statPoints": FieldValue.increment(Int64(-cost))
        ])
        HapticManager.shared.success()
    }
}
