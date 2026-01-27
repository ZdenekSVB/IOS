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
    
    // UI Stavy
    @Published var showInventory: Bool = false
    @Published var selectedItemForCompare: InventoryItem?
    @Published var selectedEquippedSlot: EquipSlot?
    
    private var db = Firestore.firestore()
    private var currentUserId: String?
    
    private var userListener: ListenerRegistration?
    private var inventoryListener: ListenerRegistration?
    
    deinit {
        stopListening()
    }
    
    func fetchData(for userId: String) {
        if currentUserId == userId && user != nil { return }

        stopListening()
        
        self.currentUserId = userId
        
        // 1. Načíst definice itemů (Master Items)
        db.collection("items").getDocuments { [weak self] snapshot, _ in
            guard let self = self, let docs = snapshot?.documents else { return }
            
            var itemsDict: [String: AItem] = [:]
            
            for doc in docs {
                if var item = try? doc.data(as: AItem.self) {
                    // Pojistka: Pokud ID chybí, vezmeme ho z dokumentu
                    if item.id == nil { item.id = doc.documentID }
                    
                    if let id = item.id {
                        itemsDict[id] = item
                    }
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
        userListener = db.collection("users").document(userId).addSnapshotListener { [weak self] snapshot, error in
            guard let self = self, let snapshot = snapshot, snapshot.exists else { return }
            
            if let updatedUser = try? snapshot.data(as: User.self) {
                DispatchQueue.main.async {
                    self.user = updatedUser
                    // Listener na inventář spustíme jen jednou, pokud ještě neběží
                    if self.inventoryListener == nil {
                        self.startListeningToInventory(userId: userId)
                    }
                }
            }
        }
    }
    
    private func startListeningToInventory(userId: String) {
        // print("🔍 Začínám naslouchat inventáři pro user: \(userId)")
        
        inventoryListener = db.collection("users").document(userId).collection("inventory").addSnapshotListener { [weak self] invSnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Chyba při načítání inventáře: \(error)")
                return
            }
            
            guard let invDocs = invSnapshot?.documents else {
                // print("⚠️ Žádné dokumenty v inventáři.")
                return
            }
            
            var loadedInv: [InventoryItem] = []
            
            for doc in invDocs {
                // Zkusíme dekódovat slot
                if let slot = try? doc.data(as: UserInventorySlot.self) {
                    // Hledáme definici
                    if let masterItem = self.masterItems[slot.itemId] {
                        loadedInv.append(InventoryItem(
                            id: doc.documentID,
                            item: masterItem,
                            quantity: slot.quantity
                        ))
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.inventoryItems = loadedInv.sorted { $0.rarityRank > $1.rarityRank }
            }
        }
    }
    
    func getEquippedItem(for slot: EquipSlot) -> AItem? {
        guard let user = user else { return nil }
        
        if let itemId = user.equippedIds[slot.id] {
            return masterItems[itemId]
        }
        return nil
    }
    
    // --- Equip s přepočtem statů ---
    func equipItem(_ newItem: InventoryItem) {
        guard let userId = currentUserId, var user = user, let slot = newItem.item.computedSlot else { return }
        
        let slotId = slot.id
        guard let itemID = newItem.item.id else { return }
        
        // 1. Zjistíme starý item a odečteme jeho staty
        if let oldItemId = user.equippedIds[slotId], let oldItem = masterItems[oldItemId] {
            applyItemStats(user: &user, item: oldItem, isEquipping: false)
        }
        
        // 2. Nasadíme nový item
        user.equippedIds[slotId] = itemID
        
        // 3. Přičteme staty nového itemu
        applyItemStats(user: &user, item: newItem.item, isEquipping: true)
        
        // Update lokálně
        self.user = user
        
        // Update Firestore (uložíme vybavené ID i nové staty)
        db.collection("users").document(userId).updateData([
            "equippedIds": user.equippedIds,
            "stats": user.stats.toDictionary()
        ])
        
        // print("Equipping \(newItem.item.name) to \(slot.id)")
    }
    
    // --- Unequip s přepočtem statů ---
    func unequipItem(slot: EquipSlot) {
        guard let userId = currentUserId, var user = user else { return }
        
        // 1. Odečteme staty
        if let oldItemId = user.equippedIds[slot.id], let oldItem = masterItems[oldItemId] {
            applyItemStats(user: &user, item: oldItem, isEquipping: false)
        }
        
        // 2. Sundáme item
        user.equippedIds.removeValue(forKey: slot.id)
        
        // Update lokálně
        self.user = user
        
        // Update Firestore
        db.collection("users").document(userId).updateData([
            "equippedIds": user.equippedIds,
            "stats": user.stats.toDictionary()
        ])
    }
    
    // --- OPRAVENO: Mapování nových názvů statů (physicalDamage, magicDamage, ...) ---
    private func applyItemStats(user: inout User, item: AItem, isEquipping: Bool) {
        let multiplier = isEquipping ? 1 : -1
        
        // Fyzický útok
        if let pAtk = item.baseStats.physicalDamage {
            user.stats.physicalDamage += (pAtk * multiplier)
        }
        
        // Magický útok
        if let mAtk = item.baseStats.magicDamage {
            user.stats.magicDamage += (mAtk * multiplier)
        }
        
        // Fyzická obrana (použijeme pro 'defense' ve statsu hráče)
        // Poznámka: Pokud má hráč rozdělenou obranu, namapuj to přesněji.
        // Zde sčítám physical + magic defense do jednoho 'defense', pokud hráč nemá separate staty.
        // Nebo pokud má 'defense', použijeme physicalDefense.
        if let pDef = item.baseStats.physicalDefense {
            user.stats.defense += (pDef * multiplier)
        }
        
        // Pokud bys měl v User.stats i 'magicDefense', přidej to sem:
        // if let mDef = item.baseStats.magicDefense { user.stats.magicDefense += ... }
        
        // Zdraví
        if let hp = item.baseStats.healthBonus {
            user.stats.maxHP += (hp * multiplier)
        }
        
        // Pojistka proti záporným/nulovým hodnotám
        user.stats.physicalDamage = max(1, user.stats.physicalDamage)
        user.stats.magicDamage = max(0, user.stats.magicDamage)
        user.stats.defense = max(0, user.stats.defense)
        user.stats.maxHP = max(10, user.stats.maxHP)
    }
    
    // --- Upgrade za Body ---
    func upgradeStat(_ stat: String, cost: Int = 1) {
        guard let userId = currentUserId, let user = user, user.statPoints >= cost else { return }
        
        let ref = db.collection("users").document(userId)
        
        ref.updateData([
            "stats.\(stat)": FieldValue.increment(Int64(1)),
            "statPoints": FieldValue.increment(Int64(-cost)) // Odečteme body
        ])
        
        HapticManager.shared.success()
    }
}
