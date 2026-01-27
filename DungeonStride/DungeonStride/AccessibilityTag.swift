//
//  AccessibilityTag.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 27.01.2026.
//

import Foundation
import SwiftUI

enum AccessibilityTag: String {
    // MARK: - Welcome View
    case welcomeLoginButton
    case welcomeSignUpButton
    
    // MARK: - Login View
    case loginBackButton
    
    // MARK: - Register View
    case registerCancelButton
    case registerButton
    
    // MARK: - Form Fields
    case registerUsernameField
    case registerEmailField
    case registerPasswordField
    case registerConfirmPasswordField
}

extension View {
    func accessibilityIdentifier(_ tag: AccessibilityTag) -> some View {
        self.accessibilityIdentifier(tag.rawValue)
    }
}