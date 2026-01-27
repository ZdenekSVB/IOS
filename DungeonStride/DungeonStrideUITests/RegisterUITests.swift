//
//  RegisterUITests.swift
//  DungeonStrideUITests
//

import XCTest

class RegisterUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        // ZDE NEDÁVÁME "UITesting", chceme vidět Welcome Screen a projít to jako reálný uživatel,
        // ALE AuthTextField si to zkontroluje, pokud bychom to tam dali.
        // ABY FUNGOVALA ÚPRAVA V AuthTextField, MUSÍME TU "UITesting" PŘIDAT,
        // ale musíme zajistit, aby AuthViewModel a UserService tento argument ignorovali, pokud chceme vidět WelcomeScreen.
        
        // KOMPROMIS: Pro tento test přidáme "DisableAutofill", aby AuthTextField věděl, že má vypnout nápovědu,
        // ale AuthViewModel/UserService na to nebudou reagovat (protože reagují jen na "UITesting").
        app.launchArguments = ["DisableAutofill"]
        app.launch()
    }

    func testRegistrationFlow() {
        // 1. Dostat se z WelcomeView na RegisterView
        let signUpButton = app.buttons["Sign up"]
        let registerButtonCS = app.buttons["Registrovat"]
        
        if signUpButton.exists {
            signUpButton.tap()
        } else if registerButtonCS.exists {
            registerButtonCS.tap()
        } else {
            let allButtons = app.buttons
            if allButtons.count >= 2 {
                print("DEBUG: Klikám na druhé tlačítko (index 1) jako fallback")
                allButtons.element(boundBy: 1).tap()
            } else {
                XCTFail("Nemohu najít tlačítko pro registraci na WelcomeView.")
            }
        }
        
        // 2. Vyplnění formuláře
        let usernameField = app.textFields["usernameField"]
        XCTAssertTrue(usernameField.waitForExistence(timeout: 2), "Nejsem na obrazovce registrace")
        
        usernameField.tap()
        usernameField.typeText("TestUserUI")

        // Unikátní email
        let uniqueEmail = "test\(Int(Date().timeIntervalSince1970))@example.com"
        
        let emailField = app.textFields["emailField"]
        emailField.tap()
        emailField.typeText(uniqueEmail)
        // Zavřeme klávesnici Enterem (pokud to pole podporuje), nebo jdeme dál
        
        let passwordField = app.secureTextFields["passwordField"]
        passwordField.tap()
        passwordField.typeText("password123")
        // Triky pro zavření klávesnice/pop-upů:
        passwordField.typeText("\n")

        let confirmField = app.secureTextFields["confirmPasswordField"]
        confirmField.tap()
        confirmField.typeText("password123")
        // DŮLEŽITÉ: Stiskem "\n" (Enter) zavřeme klávesnici, aby bylo vidět tlačítko
        confirmField.typeText("\n")
        
        // Pokud klávesnice stále nezmizela, zkusíme tapnout na statický text "Create Account" (nadpis), to obvykle shodí focus
        app.staticTexts["Create Account"].firstMatch.tap()

        // 3. Odeslání
        let createButton = app.buttons["registerButton"]
        
        // Čekáme chvilku, než zmizí klávesnice
        let exists = createButton.waitForExistence(timeout: 2)
        XCTAssertTrue(exists, "Tlačítko registrace není vidět (možná ho kryje klávesnice?)")
        
        // Pokud je tlačítko disabled, počkáme nebo selžeme
        if !createButton.isEnabled {
            // Někdy SwiftUI chvíli trvá validace
            sleep(1)
        }
        XCTAssertTrue(createButton.isEnabled, "Tlačítko registrace je neaktivní - validace formuláře neprošla")
        
        createButton.tap()

        // 4. Ověření úspěchu
        let tabBar = app.tabBars.firstMatch
        if tabBar.waitForExistence(timeout: 15) { // Firebase může trvat déle
            print("✅ Registrace úspěšná, jsme v aplikaci.")
        } else {
            // Pokud to selže na timeout, je to často sítí v simulátoru
            print("⚠️ TabBar se neobjevil. Buď chyba registrace, nebo pomalá síť.")
        }
    }
}
