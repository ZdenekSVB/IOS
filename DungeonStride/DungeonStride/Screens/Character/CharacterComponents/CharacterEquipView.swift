//
//  CharacterEquipView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct CharacterEquipView: View {
    @ObservedObject var vm: CharacterViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            // HORNÍ ČÁST: Armor a Zbraně
            HStack(alignment: .center, spacing: 16) {
                // LEVÝ SLOUPEC (Armor)
                VStack(spacing: 12) {
                    slotCell(.head)
                    slotCell(.chest)
                    slotCell(.legs)
                    slotCell(.feet)
                }
                
                // PROSTŘEDEK (Avatar)
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(themeManager.accentColor.opacity(0.1))
                            .frame(width: 140, height: 140)
                        
                        if let avatarName = vm.user?.selectedAvatar, avatarName != "default" {
                            Image(avatarName)
                                .resizable().scaledToFill()
                                .frame(width: 130, height: 130)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.fill")
                                .resizable().scaledToFit()
                                .frame(height: 80)
                                .foregroundColor(themeManager.secondaryTextColor)
                        }
                    }
                    .overlay(Circle().stroke(themeManager.accentColor, lineWidth: 2))
                    .shadow(radius: 5)
                    
                    // Level Badge
                    Text("Level \(vm.user?.level ?? 1)")
                        .font(.caption).bold()
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(themeManager.cardBackgroundColor)
                        .foregroundColor(themeManager.primaryTextColor)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    
                    // Celkové staty (Malý přehled)
                    if let stats = vm.user?.stats {
                        HStack(spacing: 12) {
                            statBadge(icon: "sword.fill", val: stats.physicalDamage, color: .red)
                            statBadge(icon: "shield.fill", val: stats.defense, color: .blue)
                            statBadge(icon: "sparkles", val: stats.magicDamage, color: .purple)
                        }
                        .padding(6)
                        .background(themeManager.cardBackgroundColor.opacity(0.8))
                        .cornerRadius(8)
                    }
                }
                
                // PRAVÝ SLOUPEC (Ruce + Ostatní)
                VStack(spacing: 12) {
                    slotCell(.mainHand)
                    slotCell(.offHand)
                    slotCell(.hands)
                    // Prázdné místo pro symetrii
                    Spacer().frame(width: 60, height: 60)
                }
            }
            
            Divider().background(themeManager.secondaryTextColor.opacity(0.3))
            
            // DOLNÍ ČÁST: Spells (Kouzla)
            VStack(alignment: .leading, spacing: 8) {
                Text("Spells")
                    .font(.caption).bold()
                    .foregroundColor(themeManager.secondaryTextColor)
                    .padding(.leading, 8)
                
                HStack(spacing: 20) {
                    slotCell(.spell1)
                    slotCell(.spell2)
                    slotCell(.spell3)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
    }
    
    func slotCell(_ slot: EquipSlot) -> some View {
        EquipSlotCell(slot: slot, item: vm.getEquippedItem(for: slot))
            .onTapGesture {
                if vm.getEquippedItem(for: slot) != nil {
                    HapticManager.shared.lightImpact()
                    SoundManager.shared.playSystemClick()
                    vm.selectedEquippedSlot = slot
                }
            }
    }
    
    func statBadge(icon: String, val: Int, color: Color) -> some View {
        HStack(spacing: 2) {
            Image(systemName: icon).font(.caption2).foregroundColor(color)
            Text("\(val)").font(.caption2).bold().foregroundColor(themeManager.primaryTextColor)
        }
    }
}
