//
//  SettingsView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//


//
//  SettingsView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var notificationsEnabled = true
    @State private var soundEffects = true
    @State private var darkMode = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Paleta3")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Account Settings
                        SettingsSection(title: "ACCOUNT") {
                            SettingsRow(icon: "person.fill", title: "Edit Profile", value: "") {
                                // Navigate to edit profile
                            }
                            
                            SettingsRow(icon: "envelope.fill", title: "Email Notifications", value: "") {
                                // Email settings
                            }
                            
                            SettingsRow(icon: "shield.fill", title: "Privacy", value: "") {
                                // Privacy settings
                            }
                        }
                        
                        // App Settings
                        SettingsSection(title: "APP SETTINGS") {
                            SettingsToggleRow(icon: "bell.fill", title: "Push Notifications", isOn: $notificationsEnabled)
                            
                            SettingsToggleRow(icon: "speaker.wave.2.fill", title: "Sound Effects", isOn: $soundEffects)
                            
                            SettingsToggleRow(icon: "moon.fill", title: "Dark Mode", isOn: $darkMode)
                            
                            SettingsRow(icon: "chart.bar.fill", title: "Units", value: "Metric") {
                                // Units settings
                            }
                        }
                        
                        // Support
                        SettingsSection(title: "SUPPORT") {
                            SettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", value: "") {
                                // Help center
                            }
                            
                            SettingsRow(icon: "exclamationmark.triangle.fill", title: "Report a Problem", value: "") {
                                // Report problem
                            }
                            
                            SettingsRow(icon: "doc.text.fill", title: "Terms of Service", value: "") {
                                // Terms of service
                            }
                            
                            SettingsRow(icon: "lock.shield.fill", title: "Privacy Policy", value: "") {
                                // Privacy policy
                            }
                        }
                        
                        // App Info
                        SettingsSection(title: "ABOUT") {
                            SettingsRow(icon: "info.circle.fill", title: "Version", value: "1.0.0") {
                                // Version info
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color("Paleta2"))
                }
            }
        }
    }
}

// MARK: - Settings Components
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color("Paleta4"))
                .padding(.horizontal, 4)
            
            VStack(spacing: 1) {
                content
            }
            .background(Color("Paleta5"))
            .cornerRadius(12)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(Color("Paleta2"))
                    .frame(width: 30)
                
                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                
                Spacer()
                
                if !value.isEmpty {
                    Text(value)
                        .foregroundColor(Color("Paleta4"))
                        .font(.system(size: 14))
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color("Paleta4"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color("Paleta5"))
        }
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color("Paleta2"))
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 16))
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: Color("Paleta2")))
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color("Paleta5"))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}