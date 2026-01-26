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
        HStack(alignment: .center, spacing: 20) {
            // LEVÝ SLOUPEC
            VStack(spacing: 15) {
                slotCell(.head); slotCell(.chest); slotCell(.hands); slotCell(.legs)
            }
            // PROSTŘEDEK (Avatar)
            VStack {
                ZStack {
                    Circle().fill(Color.blue.opacity(0.1)).frame(width: 140, height: 140)
                    Image(systemName: "person.fill").resizable().scaledToFit().frame(height: 100).foregroundColor(.gray)
                }
                Text("Level \(vm.user?.level ?? 1)").font(.caption).bold().padding(4).background(Color.black.opacity(0.1)).cornerRadius(5)
            }
            // PRAVÝ SLOUPEC
            VStack(spacing: 15) {
                slotCell(.mainHand); slotCell(.offHand); slotCell(.feet); Spacer().frame(width: 55, height: 55)
            }
        }
        .padding()
    }
    
    func slotCell(_ slot: EquipSlot) -> some View {
        EquipSlotCell(slot: slot, item: vm.getEquippedItem(for: slot))
            .onTapGesture {
                if vm.getEquippedItem(for: slot) != nil {
                    // Haptika při otevření detailu nasazeného itemu
                    HapticManager.shared.lightImpact()
                    SoundManager.shared.playSystemClick()
                    vm.selectedEquippedSlot = slot
                }
            }
    }
}
