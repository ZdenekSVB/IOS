//
//  SettingsSupportSection.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//


import SwiftUI
struct SettingsSupportSection: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    // URL
    private let reportProblemURL = URL(string: "https://forms.gle/N6SHg5RRvKrKUpqs6")!
    private let privacyPolicyURL = URL(string: "https://www.apple.com/legal/privacy/en-ww/")!
    
    var body: some View {
        SettingsSection(title: "SUPPORT", themeManager: themeManager) {
            
            // Report Problem
            SettingsRow(
                icon: "exclamationmark.bubble.fill",
                title: "Report a Problem",
                color: .orange,
                showExternalIcon: true,
                themeManager: themeManager
            ) {
                UIApplication.shared.open(reportProblemURL)
            }
            
            // Contact Us
            NavigationLink(destination: ContactUsView()) {
                SettingsNavigationRow(
                    icon: "envelope.fill",
                    title: "Contact Us",
                    color: .blue,
                    themeManager: themeManager
                )
            }
            
            // Terms
            NavigationLink(destination: TermsOfServiceView()) {
                SettingsNavigationRow(
                    icon: "doc.text.fill",
                    title: "Terms of Service",
                    color: themeManager.secondaryTextColor,
                    themeManager: themeManager
                )
            }
            
            // Privacy
            SettingsRow(
                icon: "hand.raised.fill",
                title: "Privacy Policy",
                color: .gray,
                showExternalIcon: true,
                themeManager: themeManager
            ) {
                UIApplication.shared.open(privacyPolicyURL)
            }
        }
    }
}
