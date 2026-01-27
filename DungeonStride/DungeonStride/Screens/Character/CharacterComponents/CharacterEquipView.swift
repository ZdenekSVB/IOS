//
//  CharacterEquipView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct CharacterEquipView: View {
    @ObservedObject var vm: CharacterViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 20) {
                // LEVÝ SLOUPEC
                VStack(spacing: 12) {
                    slotCell(.head); slotCell(.chest); slotCell(.hands); slotCell(.legs)
                }
                
                // PROSTŘEDEK (Avatar + Celkové Staty)
                VStack(spacing: 12) {
                    ZStack {
                        Circle().fill(Color.blue.opacity(0.1)).frame(width: 130, height: 130)
                        
                        if let avatarName = vm.user?.selectedAvatar, avatarName != "default" {
                            Image(avatarName)
                                .resizable().scaledToFit().frame(height: 110).clipShape(Circle())
                        } else {
                            Image(systemName: "person.fill").resizable().scaledToFit().frame(height: 90).foregroundColor(.gray)
                        }
                    }
                    .overlay(Circle().stroke(Color.blue.opacity(0.5), lineWidth: 2))
                    
                    Text("Level \(vm.user?.level ?? 1)")
                        .font(.caption).bold()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(5)
                    
                    // --- CELKOVÉ STATISTIKY (Přidáno) ---
                    if let stats = vm.user?.stats {
                        VStack(spacing: 4) {
                            statBadge(icon: "flame.fill", value: stats.physicalDamage, color: .red)
                            statBadge(icon: "shield.fill", value: stats.defense, color: .blue)
                            statBadge(icon: "sparkles", value: stats.magicDamage, color: .purple)
                            statBadge(icon: "heart.fill", value: stats.maxHP, color: .green)
                        }
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                    }
                }
                
                // PRAVÝ SLOUPEC
                VStack(spacing: 12) {
                    slotCell(.mainHand); slotCell(.offHand); slotCell(.feet); Spacer().frame(width: 55, height: 55)
                }
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
    
    func statBadge(icon: String, value: Int, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption2).foregroundColor(color)
            Text("\(value)").font(.caption2).bold()
        }
    }
}
