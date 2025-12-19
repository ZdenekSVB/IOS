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
            
            db.collection("items").getDocuments { [weak self] snapshot, _ in
                guard let self = self, let docs = snapshot?.documents else { return }
                
                var itemsDict: [String: AItem] = [:]
                
                for doc in docs {
                    if let item = try? doc.data(as: AItem.self) {
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
                        if self.inventoryListener == nil {
                            self.startListeningToInventory(userId: userId)
                        }
                    }
                }
            }
        }
        
    private func startListeningToInventory(userId: String) {
            print("🔍 Začínám naslouchat inventáři pro user: \(userId)")
            
            inventoryListener = db.collection("users").document(userId).collection("inventory").addSnapshotListener { [weak self] invSnapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Chyba při načítání inventáře: \(error)")
                    return
                }
                
                guard let invDocs = invSnapshot?.documents else {
                    print("⚠️ Žádné dokumenty v inventáři.")
                    return
                }
                
                print("📦 Načteno \(invDocs.count) dokumentů z inventáře (raw).")
                print("📚 Počet známých master itemů: \(self.masterItems.count)")
                
                var loadedInv: [InventoryItem] = []
                
                for doc in invDocs {
                    // Zkusíme dekódovat slot
                    if let slot = try? doc.data(as: UserInventorySlot.self) {
                        print("   👉 Zkouším item s ID: '\(slot.itemId)'")
                        
                        // Hledáme definici
                        if let masterItem = self.masterItems[slot.itemId] {
                            print("      ✅ Nalezen v Master datech: \(masterItem.name)")
                            loadedInv.append(InventoryItem(
                                id: doc.documentID,
                                item: masterItem,
                                quantity: slot.quantity
                            ))
                        } else {
                            print("      ❌ CHYBA: Item '\(slot.itemId)' v Master datech NEEXISTUJE!")
                            print("         (Dostupná ID jsou např.: \(self.masterItems.keys.prefix(3))...)")
                        }
                    } else {
                        print("   ❌ Chyba dekódování UserInventorySlot")
                    }
                }
                
                DispatchQueue.main.async {
                    self.inventoryItems = loadedInv.sorted { $0.rarityRank > $1.rarityRank }
                    print("🏁 Finální počet itemů v UI: \(self.inventoryItems.count)")
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
        
        func equipItem(_ newItem: InventoryItem) {
            guard let userId = currentUserId, var user = user, let slot = newItem.item.computedSlot else { return }
            
            let slotId = slot.id
            let newItemId = newItem.item.id ?? ""
            let dbItemId = newItem.item.id
           
            var newEquipMap = user.equippedIds
            newEquipMap[slotId] = newItem.item.id
            
            user.equippedIds = newEquipMap
            self.user = user
            
            db.collection("users").document(userId).updateData(["equippedIds": newEquipMap])
            
            print("Equipping \(newItem.item.name) to \(slot.id)")
        }
                func upgradeStat(_ stat: String, cost: Int) {
            guard let userId = currentUserId, let user = user, user.coins >= cost else { return }
            
            let ref = db.collection("users").document(userId)
            
            ref.updateData([
                "stats.\(stat)": FieldValue.increment(Int64(1)),
                "coins": FieldValue.increment(Int64(-cost))
            ])
        }
    
    func unequipItem(slot: EquipSlot) {
        guard let userId = currentUserId, var user = user else { return }
        
        // Odstraníme item ze slotu
        var newEquipMap = user.equippedIds
        newEquipMap.removeValue(forKey: slot.id)
        
        // Update lokálně (aby to zmizelo hned)
        user.equippedIds = newEquipMap
        self.user = user
        
        // Update Firestore
        // Poznámka: V reálu bys měl item vrátit do pole "inventory",
        // pro teď ho jen smažeme z equipu.
        let db = Firestore.firestore()
        db.collection("users").document(userId).updateData([
            "equippedIds": newEquipMap
        ])
    }
}
