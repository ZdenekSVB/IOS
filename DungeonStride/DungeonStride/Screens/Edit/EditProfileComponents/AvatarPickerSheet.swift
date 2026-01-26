//
//  AvatarPickerSheet.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//


import SwiftUI

struct AvatarPickerSheet: View {
    @Binding var selectedAvatar: String
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    let avatars = ["avatar1", "avatar2", "avatar3", "avatar4", "avatar5", "avatar6"]
    let columns = [GridItem(.adaptive(minimum: 100))]
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Vyberte si hrdinu")
                    .font(.headline)
                    .foregroundColor(themeManager.primaryTextColor)
                    .padding(.top, 20)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(avatars, id: \.self) { avatarName in
                            AvatarGridItem(
                                avatarName: avatarName,
                                isSelected: selectedAvatar == avatarName,
                                accentColor: themeManager.accentColor,
                                onTap: {
                                    selectedAvatar = avatarName
                                    dismiss()
                                }
                            )
                        }
                    }
                    .padding()
                }
                
                Button("Zrušit") { dismiss() }
                    .foregroundColor(.red)
                    .padding(.bottom, 20)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
