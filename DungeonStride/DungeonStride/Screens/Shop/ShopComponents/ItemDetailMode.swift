//
//  ItemDetailSheet.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 27.01.2026.
//

import SwiftUI

enum ItemDetailMode {
    case equip(onEquip: () -> Void, onSell: () -> Void, sellPrice: Int)
    case unequip(onUnequip: () -> Void)
    case buy(price: Int, onBuy: () -> Void)
    case viewOnly
}

struct ItemDetailSheet: View {
    let item: AItem
    let equippedItem: AItem?
    let user: User
    let mode: ItemDetailMode
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 1. HEADER
                        VStack(spacing: 16) {
                            ItemIconView(item: item, size: 120)
                                .shadow(radius: 8)
                            
                            VStack(spacing: 4) {
                                Text(item.name)
                                    .font(.title2).bold()
                                    .foregroundColor(themeManager.primaryTextColor)
                                    .multilineTextAlignment(.center)
                                
                                Text(item.itemType.uppercased())
                                    .font(.caption).bold()
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(item.rarity?.color.opacity(0.2) ?? Color.gray.opacity(0.2))
                                    .foregroundColor(item.rarity?.color ?? .gray)
                                    .cornerRadius(8)
                            }
                            
                            Text(item.description)
                                .font(.body)
                                .foregroundColor(themeManager.secondaryTextColor)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top)
                        
                        Divider().background(themeManager.secondaryTextColor.opacity(0.3))
                        
                        // 2. STATS / INFO
                        VStack(alignment: .leading, spacing: 12) {
                            // Rozlišení typu itemu
                            if item.itemType == "Potion" || item.itemType == "Consumable" {
                                // Zobrazení pro Consumables
                                Text("EFFECTS")
                                    .font(.caption).bold().foregroundColor(themeManager.secondaryTextColor)
                                    .padding(.leading)
                                
                                VStack(spacing: 12) {
                                    if let hp = item.finalHealthBonus, hp > 0 {
                                        consumableRow(text: "Restores \(hp) Health", icon: "heart.fill", color: .green)
                                    }
                                    if let mana = item.finalManaBonus, mana > 0 {
                                        consumableRow(text: "Restores \(mana) Mana", icon: "sparkles", color: .blue)
                                    }
                                    // Fallback
                                    if (item.finalHealthBonus ?? 0) <= 0 && (item.finalManaBonus ?? 0) <= 0 {
                                        Text("No special effects.")
                                            .foregroundColor(themeManager.secondaryTextColor)
                                            .padding()
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(themeManager.cardBackgroundColor)
                                .cornerRadius(12)
                                .padding(.horizontal)
                                
                            } else {
                                // Zobrazení pro Equipment (Staty)
                                HStack {
                                    Text("STATISTICS")
                                        .font(.caption).bold().foregroundColor(themeManager.secondaryTextColor)
                                    Spacer()
                                    if case .unequip = mode {
                                        Text("Change on Unequip").font(.caption).foregroundColor(themeManager.secondaryTextColor)
                                    } else {
                                        Text("Change on Equip").font(.caption).foregroundColor(themeManager.secondaryTextColor)
                                    }
                                }
                                .padding(.horizontal)
                                
                                VStack(spacing: 0) {
                                    statRow(title: "Physical Dmg", icon: "sword.fill", baseVal: item.finalPhysicalDamage, equippedVal: equippedItem?.finalPhysicalDamage, totalVal: user.stats.physicalDamage)
                                    statRow(title: "Magic Dmg", icon: "flame.fill", baseVal: item.finalMagicDamage, equippedVal: equippedItem?.finalMagicDamage, totalVal: user.stats.magicDamage)
                                    statRow(title: "Defense", icon: "shield.fill", baseVal: item.finalPhysicalDefense, equippedVal: equippedItem?.finalPhysicalDefense, totalVal: user.stats.defense)
                                    statRow(title: "Health Max", icon: "heart.fill", baseVal: item.finalHealthBonus, equippedVal: equippedItem?.finalHealthBonus, totalVal: user.stats.maxHP)
                                }
                                .background(themeManager.cardBackgroundColor)
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer(minLength: 20)
                        
                        // 3. ACTION BUTTONS
                        actionButtons
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }.foregroundColor(themeManager.accentColor)
                }
            }
        }
    }
    
    // --- POMOCNÉ VIEWS ---
    
    func consumableRow(text: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 30)
            Text(text)
                .font(.headline)
                .foregroundColor(themeManager.primaryTextColor)
            Spacer()
        }
    }
    
    func statRow(title: String, icon: String, baseVal: Int?, equippedVal: Int?, totalVal: Int) -> some View {
        var newVal = baseVal ?? 0
        var oldVal = equippedVal ?? 0
        
        if case .unequip = mode {
            newVal = 0
            oldVal = baseVal ?? 0
        }
        
        guard newVal > 0 || oldVal > 0 else { return AnyView(EmptyView()) }
        
        let diff = newVal - oldVal
        let projectedTotal = totalVal + diff
        
        return AnyView(
            VStack(spacing: 0) {
                HStack {
                    Label {
                        Text(title).font(.subheadline).foregroundColor(themeManager.primaryTextColor)
                    } icon: {
                        Image(systemName: icon).foregroundColor(themeManager.secondaryTextColor)
                    }
                    Spacer()
                    
                    if diff != 0 {
                        Text(diff > 0 ? "+\(diff)" : "\(diff)")
                            .font(.body).bold()
                            .foregroundColor(diff > 0 ? .green : .red)
                            .padding(.trailing, 8)
                    } else {
                        Text("-").foregroundColor(themeManager.secondaryTextColor).padding(.trailing, 8)
                    }
                    
                    HStack(spacing: 2) {
                        Text("\(totalVal)").font(.caption).foregroundColor(themeManager.secondaryTextColor).strikethrough()
                        Image(systemName: "arrow.right").font(.caption2).foregroundColor(themeManager.secondaryTextColor)
                        Text("\(projectedTotal)").font(.caption).bold()
                            .foregroundColor(projectedTotal > totalVal ? .green : (projectedTotal < totalVal ? .red : themeManager.primaryTextColor))
                    }
                    .padding(4)
                    .background(themeManager.backgroundColor)
                    .cornerRadius(4)
                }
                .padding()
                Divider().background(themeManager.secondaryTextColor.opacity(0.2)).padding(.leading, 40)
            }
        )
    }
    
    @ViewBuilder
    var actionButtons: some View {
        switch mode {
        case .equip(let onEquip, let onSell, let sellPrice):
            VStack(spacing: 12) {
                // Pokud je to Potion/Consumable, text bude "USE", jinak "EQUIP"
                Button(action: {
                    HapticManager.shared.success()
                    onEquip()
                    dismiss()
                }) {
                    Text(item.itemType == "Potion" ? "USE" : "EQUIP")
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


struct ItemIconView: View {
    let item: AItem
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Pozadí
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
            
            // Obrázek
            if item.isSystemIcon {
                Image(systemName: item.iconName)
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.25) // Padding pro systémové ikony
                    .foregroundColor(item.rarity?.color ?? .gray)
            } else {
                Image(item.iconName)
                    .resizable()
                    .scaledToFill() // Roztáhneme přes celý prostor
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: 16)) // Ořízneme podle tvaru
            }
        }
        .frame(width: size, height: size)
        // Ohraniceni (Border)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(item.rarity?.color ?? .gray, lineWidth: 3)
        )
    }
}
