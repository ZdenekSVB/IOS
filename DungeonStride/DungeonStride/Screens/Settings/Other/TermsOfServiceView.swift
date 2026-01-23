//
//  TermsOfServiceView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 23.01.2026.
//


//
//  TermsOfServiceView.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 14.10.2025.
//

import SwiftUI

struct TermsOfServiceView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Terms of Service")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(themeManager.primaryTextColor)
                    
                    Text("Last updated: October 2025")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                .padding(.bottom, 10)
                
                Divider()
                    .background(themeManager.secondaryTextColor)
                
                // Content
                Group {
                    tosSection(title: "1. Acceptance of Terms", text: "By downloading and using DungeonStride, you agree to comply with and be bound by these Terms of Service. If you do not agree to these terms, please do not use the application.")
                    
                    tosSection(title: "2. Health Disclaimer", text: "DungeonStride encourages physical activity. However, you should consult your physician or other health care professional before starting this or any other fitness program to determine if it is right for your needs. Use of this app is at your own risk.")
                    
                    tosSection(title: "3. User Accounts", text: "You are responsible for maintaining the confidentiality of your account credentials. You agree to notify us immediately of any unauthorized use of your account.")
                    
                    tosSection(title: "4. Privacy", text: "Your use of the app is also governed by our Privacy Policy. We respect your data and do not share your location data with third parties without your consent.")
                    
                    tosSection(title: "5. Termination", text: "We reserve the right to terminate or suspend access to our service immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.")
                    
                    tosSection(title: "6. Contact", text: "If you have any questions about these Terms, please contact us via the settings menu in the application.")
                }
                
                Spacer(minLength: 50)
            }
            .padding()
        }
        .background(themeManager.backgroundColor.ignoresSafeArea())
        .navigationTitle("Terms")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Pomocná funkce pro odstavce
    @ViewBuilder
    private func tosSection(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(themeManager.primaryTextColor)
            
            Text(text)
                .font(.body)
                .foregroundColor(themeManager.secondaryTextColor)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}