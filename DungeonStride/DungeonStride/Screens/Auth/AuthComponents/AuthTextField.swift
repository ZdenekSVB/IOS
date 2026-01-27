//
//  AuthTextField.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct AuthTextField: View {
    let title: LocalizedStringKey
    let placeholder: LocalizedStringKey
    @Binding var text: String
    let isSecure: Bool
    var testID: String? = nil
    
    // Detekce testovacího režimu
    private var isTesting: Bool {
        CommandLine.arguments.contains("UITesting")
    }
    
    // Init se vším
    init(title: LocalizedStringKey, placeholder: LocalizedStringKey, text: Binding<String>, isSecure: Bool, testID: String? = nil) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.testID = testID
    }
    
    // Zpětná kompatibilita
    init(title: LocalizedStringKey, text: Binding<String>, isSecure: Bool) {
        self.init(title: title, placeholder: "Enter text", text: text, isSecure: isSecure, testID: nil)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    // POKUD TESTUJEME, VYPNEME AUTOFILL A SUGGESTIONS
                    .textContentType(isTesting ? .oneTimeCode : .password)
                    .accessibilityIdentifier(testID ?? "")
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .textContentType(isTesting ? .oneTimeCode : .emailAddress)
                    .accessibilityIdentifier(testID ?? "")
            }
        }
    }
}
