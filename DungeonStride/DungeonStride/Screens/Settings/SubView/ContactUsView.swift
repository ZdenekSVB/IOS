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
    
    // Alert stavy
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
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
                    print("📧 Tlačítko Email stisknuto")
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
                    print("📞 Tlačítko Telefon stisknuto")
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
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    // MARK: - Actions
    
    private func openMail() {
        // Vytvoření URL
        guard let url = URL(string: "mailto:\(supportEmail)") else {
            print("❌ Chyba: Neplatná URL pro email")
            return
        }
        
        // Pokus o otevření
        UIApplication.shared.open(url) { success in
            if success {
                print("✅ Email aplikace otevřena")
            } else {
                print("⚠️ Email aplikaci se nepodařilo otevřít (např. Simulátor)")
                // Fallback: Zkopírovat do schránky
                UIPasteboard.general.string = supportEmail
                alertTitle = "Email zkopírován"
                alertMessage = "Nemáte nastavenou aplikaci pro email. Adresa byla zkopírována do schránky."
                showAlert = true
            }
        }
    }
    
    private func openPhone() {
        // 1. Odstraníme mezery a závorky, necháme jen čísla a +
        let cleanPhone = supportPhone.components(separatedBy: CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "+")).inverted).joined()
        
        print("📞 Volám číslo: \(cleanPhone)")
        
        // 2. Vytvoříme URL tel://
        guard let url = URL(string: "tel://\(cleanPhone)") else {
            print("❌ Chyba: Neplatná URL pro telefon")
            return
        }
        
        // 3. Otevřeme
        UIApplication.shared.open(url) { success in
            if success {
                print("✅ Telefon otevřen")
            } else {
                print("⚠️ Nelze volat (Simulátor nebo iPad)")
                // Fallback: Zkopírovat do schránky
                UIPasteboard.general.string = supportPhone
                alertTitle = "Nelze volat"
                alertMessage = "Toto zařízení neumí volat. Číslo bylo zkopírováno do schránky."
                showAlert = true
            }
        }
    }
}
