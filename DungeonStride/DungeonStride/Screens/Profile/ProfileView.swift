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
            // Pozadí se překreslí automaticky, protože je přímo v body
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
                .padding(.bottom, 50)
            }
            // --- DŮLEŽITÁ OPRAVA ---
            // Tímto donutíme SwiftUI kompletně překreslit celý obsah ScrollView,
            // pokud se změní uživatel (updatedAt) NEBO pokud se změní téma (isDarkMode).
            .id(combinedID)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView()
        }
        .onAppear {
            if let uid = authViewModel.currentUserUID {
                // Refresh dat při zobrazení
            }
        }
    }
    
    // Pomocná proměnná pro ID
    private var combinedID: String {
        let userTimestamp = userService.currentUser?.updatedAt.timeIntervalSince1970 ?? 0
        let themeID = themeManager.isDarkMode ? "dark" : "light"
        return "\(userTimestamp)-\(themeID)"
    }
}
