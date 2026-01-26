//
//  AuthTextField.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import SwiftUI

struct AuthTextField: View {
    let title: LocalizedStringKey
    let placeholder: LocalizedStringKey // Nový parametr pro placeholder
    @Binding var text: String
    let isSecure: Bool
    
    // Init pro zpětnou kompatibilitu, pokud chceš jen title
    init(title: LocalizedStringKey, text: Binding<String>, isSecure: Bool) {
        self.title = title
        // Vytvoříme placeholder jako "Enter your [title]"
        // Poznámka: Toto je složitější na lokalizaci, lepší je poslat celý string.
        // Pro teď to necháme takto, ale ideálně bys měl posílat placeholder zvlášť.
        self.placeholder = "Enter text"
        self._text = text
        self.isSecure = isSecure
    }
    
    // Init s explicitním placeholderem (doporučeno)
    init(title: LocalizedStringKey, placeholder: LocalizedStringKey, text: Binding<String>, isSecure: Bool) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
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
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
        }
    }
}
