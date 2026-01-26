//
//  ProfileView.swift
//  DungeonStride
//

import SwiftUI

struct ProfileView: View {
    // Tyto objekty přicházejí z hlavní aplikace (jsou sdílené)
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userService: UserService
    
    // ViewModel řeší jen lokální stav této obrazovky (např. otevření sheetu)
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    if let user = userService.currentUser {
                        // 1. Hlavička (Avatar, Jméno, XP)
                        ProfileHeaderView(
                            showSettings: $viewModel.showSettings,
                            user: user,
                            themeManager: themeManager
                        )
                        
                        // 2. Mřížka statistik
                        StatsGridView(user: user, themeManager: themeManager)
                        
                        // 3. Odkaz na historii
                        HistoryLinkView(themeManager: themeManager)
                        
                        // Zde je místo pro další obsah (např. poslední úspěchy atd.)
                    } else {
                        // Loading stav
                        if authViewModel.currentUserUID == nil {
                            Text("Not logged in.") // Lokalizace
                                .foregroundColor(themeManager.secondaryTextColor)
                                .padding()
                        } else {
                            ProgressView("Loading hero...") // Lokalizace
                                .padding()
                                .tint(themeManager.accentColor)
                                .foregroundColor(themeManager.secondaryTextColor)
                        }
                    }
                }
                .padding(.top, 10)
                // Přidáme trochu místa dole, aby obsah nebyl schovaný za TabBarem
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView()
        }
    }
}
