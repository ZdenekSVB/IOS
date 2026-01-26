//
//  ContactUsView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//



import SwiftUI

struct ContactUsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    // Kontaktní údaje
    private let supportEmail = "support@dungeonstride.app"
    private let supportPhone = "+420 555 019 283"
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "headset")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(themeManager.accentColor)
                    .padding(.bottom, 10)
                
                Text("We're here to help!")
                    .font(.title2)
                    .bold()
                    .foregroundColor(themeManager.primaryTextColor)
                
                Text("Do you have questions about the game or need technical support? Choose a method below.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(themeManager.secondaryTextColor)
                    .padding(.horizontal, 32)
                
                Spacer().frame(height: 30)
                
                // Tlačítko pro Email
                Button(action: {
                    openMail()
                }) {
                    HStack {
                        Image(systemName: "envelope.fill")
                        Text("Send Email")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Tlačítko pro Telefon
                Button(action: {
                    openPhone()
                }) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("Call Support")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
                Spacer()
            }
        }
        .navigationTitle("Contact Us")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Actions
    
    private func openMail() {
        print("📧 Pokus o otevření emailu...") // Pro debugging v konzoli
        
        // Vytvoříme URL mailto:support@...
        if let url = URL(string: "mailto:\(supportEmail)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                print("❌ Zařízení nemůže poslat email (např. simulátor nebo chybí Mail app).")
            }
        }
    }
    
    private func openPhone() {
        print("📞 Pokus o vytáčení čísla...") // Pro debugging v konzoli
        
        // Odstraníme mezery z čísla, aby to systém pochopil (např. +420123456789)
        let cleanPhone = supportPhone.replacingOccurrences(of: " ", with: "")
        
        // Použijeme schéma "tel:"
        if let url = URL(string: "tel:\(cleanPhone)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                print("❌ Zařízení nemůže volat (např. simulátor nebo iPad bez SIM).")
            }
        }
    }
}
