//
//  WelcomeViewUITests.swift
//  DungeonStrideUITests
//

import XCTest

final class WelcomeViewUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testWelcomeScreenNavigation() throws {
        // --- 1. KONTROLA LOGIN NAVIGACE ---
        
        // Použití AccessibilityTag pro nalezení tlačítka
        let welcomeLoginButton = app.buttons[AccessibilityTag.welcomeLoginButton.rawValue]
        XCTAssertTrue(welcomeLoginButton.exists, "Tlačítko Login na úvodní obrazovce chybí.")
        
        welcomeLoginButton.tap()
        
        // Ověření LoginView pomocí Back tlačítka
        let loginBackButton = app.buttons[AccessibilityTag.loginBackButton.rawValue]
        XCTAssertTrue(loginBackButton.waitForExistence(timeout: 2), "Měla by se otevřít obrazovka LoginView.")
        
        loginBackButton.tap()
        
        // Ověření návratu
        XCTAssertTrue(welcomeLoginButton.waitForExistence(timeout: 2), "Návrat z LoginView selhal.")
        
        
        // --- 2. KONTROLA REGISTER NAVIGACE ---
        
        let welcomeSignUpButton = app.buttons[AccessibilityTag.welcomeSignUpButton.rawValue]
        XCTAssertTrue(welcomeSignUpButton.exists, "Tlačítko Sign Up na úvodní obrazovce chybí.")
        
        welcomeSignUpButton.tap()
        
        // Ověření RegisterView pomocí Cancel tlačítka
        let registerCancelButton = app.buttons[AccessibilityTag.registerCancelButton.rawValue]
        XCTAssertTrue(registerCancelButton.waitForExistence(timeout: 2), "Měla by se otevřít obrazovka RegisterView.")
        
        registerCancelButton.tap()
        
        // Ověření návratu
        XCTAssertTrue(welcomeLoginButton.waitForExistence(timeout: 2), "Návrat z RegisterView selhal.")
    }
}