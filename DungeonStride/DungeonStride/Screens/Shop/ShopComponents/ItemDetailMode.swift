//
//  ItemDetailSheet.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 27.01.2026.
//

import SwiftUI

// Rozšířený enum o Prodej a Unequip
enum ItemDetailMode {
    case equip(onEquip: () -> Void, onSell: () -> Void, sellPrice: Int) // Equip nebo Sell
    case unequip(onUnequip: () -> Void)                                 // Sundat
    case buy(price: Int, onBuy: () -> Void)                             // Koupit
    case viewOnly
}

struct ItemDetailSheet: View {
    let item: AItem                  // Předmět, na který koukáme
    let equippedItem: AItem?         // Co máme momentálně nasazeno (pro porovnání)
    let user: User                   // Pro výpočet celkových statů
    let mode: ItemDetailMode         // Co s tím můžeme dělat
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // 1. HEADER
                    VStack(spacing: 16) {
                        ZStack {
                            // Pozadí buňky
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(UIColor.secondarySystemBackground))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(item.rarity?.color ?? .gray, lineWidth: 4)
                                )
                            
                            // Velký obrázek bez mezer
                            if item.isSystemIcon {
                                Image(systemName: item.iconName)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(20) // U systémových ikon trochu paddingu necháme
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(item.rarity?.color ?? .gray)
                            } else {
                                Image(item.iconName)
                                    .resizable()
                                    .scaledToFit() // Roztáhne se na maximum v rámci čtverce
                                    .frame(width: 110, height: 110)
                            }
                        }
                        
                        VStack(spacing: 4) {
                            Text(item.name)
                                .font(.title2).bold()
                                .multilineTextAlignment(.center)
                            
                            Text(item.rarity?.rawValue ?? "Unknown")
                                .font(.caption).bold()
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background((item.rarity?.color ?? .gray).opacity(0.2))
                                .foregroundColor(item.rarity?.color ?? .gray)
                                .cornerRadius(8)
                            
                            Text(item.itemType)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(item.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    Divider()
                    
                    // 2. STAT COMPARISON
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("STATISTICS")
                                .font(.caption).bold().foregroundColor(.secondary)
                            Spacer()
                            Text("Total after change")
                                .font(.caption).foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            statRow(title: "Physical Dmg", icon: "sword.fill", baseVal: item.finalPhysicalDamage, equippedVal: equippedItem?.finalPhysicalDamage, totalVal: user.stats.physicalDamage)
                            
                            statRow(title: "Magic Dmg", icon: "flame.fill", baseVal: item.finalMagicDamage, equippedVal: equippedItem?.finalMagicDamage, totalVal: user.stats.magicDamage)
                            
                            statRow(title: "Defense", icon: "shield.fill", baseVal: item.finalPhysicalDefense, equippedVal: equippedItem?.finalPhysicalDefense, totalVal: user.stats.defense)
                            
                            statRow(title: "Health", icon: "heart.fill", baseVal: item.finalHealthBonus, equippedVal: equippedItem?.finalHealthBonus, totalVal: user.stats.maxHP)
                        }
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 20)
                    
                    // 3. ACTION BUTTONS
                    actionButtons
                        .padding(.horizontal)
                        .padding(.bottom)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
    
    // --- LOGIKA POROVNÁNÍ ---
    func statRow(title: String, icon: String, baseVal: Int?, equippedVal: Int?, totalVal: Int) -> some View {
        // Logika pro UNEQUIP: Pokud sundavám item, "baseVal" je 0 (protože slot bude prázdný)
        // a "equippedVal" je stat toho itemu.
        
        var newVal = baseVal ?? 0
        var oldVal = equippedVal ?? 0
        
        // Specifická úprava pro Unequip režim:
        if case .unequip = mode {
            newVal = 0          // Po změně tam nebude nic
            oldVal = baseVal ?? 0 // Aktuálně je tam tento item (item == equippedItem v tomto kontextu)
        }
        
        guard newVal > 0 || oldVal > 0 else { return AnyView(EmptyView()) }
        
        let diff = newVal - oldVal
        let projectedTotal = totalVal + diff
        
        return AnyView(
            VStack(spacing: 0) {
                HStack {
                    Label {
                        Text(title).font(.subheadline).fontWeight(.medium)
                    } icon: {
                        Image(systemName: icon).foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Zobrazení změny (+5)
                    if diff != 0 {
                        Text(diff > 0 ? "+\(diff)" : "\(diff)")
                            .font(.body).bold()
                            .foregroundColor(diff > 0 ? .green : .red)
                            .padding(.trailing, 8)
                    } else {
                        Text("-").foregroundColor(.gray).padding(.trailing, 8)
                    }
                    
                    // Celkový dopad (-> 150)
                    HStack(spacing: 2) {
                        Text("\(totalVal)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .strikethrough()
                        
                        Image(systemName: "arrow.right").font(.caption2).foregroundColor(.gray)
                        
                        Text("\(projectedTotal)")
                            .font(.caption).bold()
                            .foregroundColor(projectedTotal > totalVal ? .green : (projectedTotal < totalVal ? .red : .primary))
                    }
                    .padding(6)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(6)
                }
                .padding()
                Divider().padding(.leading, 40)
            }
        )
    }
    
    @ViewBuilder
    var actionButtons: some View {
        switch mode {
        case .equip(let onEquip, let onSell, let sellPrice):
            VStack(spacing: 12) {
                Button(action: {
                    HapticManager.shared.success()
                    onEquip()
                    dismiss()
                }) {
                    Text("EQUIP")
                        .bold().frame(maxWidth: .infinity).padding()
                        .background(Color.blue).foregroundColor(.white).cornerRadius(12)
                }
                
                Button(action: {
                    HapticManager.shared.warning()
                    onSell()
                    dismiss()
                }) {
                    HStack {
                        Text("SELL FOR \(sellPrice)")
                        Image(systemName: "dollarsign.circle.fill")
                    }
                    .font(.subheadline).bold()
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red, lineWidth: 1))
                }
            }
            
        case .unequip(let onUnequip):
            Button(action: {
                HapticManager.shared.lightImpact()
                onUnequip()
                dismiss()
            }) {
                Text("UNEQUIP")
                    .bold().frame(maxWidth: .infinity).padding()
                    .background(Color.orange).foregroundColor(.white).cornerRadius(12)
            }
            
        case .buy(let price, let onBuy):
            let canAfford = user.coins >= price
            Button(action: {
                if canAfford {
                    HapticManager.shared.success()
                    onBuy()
                    dismiss()
                } else {
                    HapticManager.shared.error()
                }
            }) {
                HStack {
                    Text("BUY FOR \(price)")
                    Image(systemName: "dollarsign.circle.fill")
                }
                .bold().frame(maxWidth: .infinity).padding()
                .background(canAfford ? Color.green : Color.gray)
                .foregroundColor(.white).cornerRadius(12)
            }
            .disabled(!canAfford)
            
        case .viewOnly:
            Button("Close") { dismiss() }
                .frame(maxWidth: .infinity).padding()
                .background(Color.gray.opacity(0.2)).cornerRadius(12)
        }
    }
}
