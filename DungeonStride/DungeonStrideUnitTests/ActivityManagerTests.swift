//
//  ActivityManagerTests.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 27.01.2026.
//


//
//  ActivityManagerTests.swift
//  DungeonStrideTests
//

import XCTest
@testable import DungeonStride // Důležité: Zpřístupní kód tvé aplikace pro testy

class ActivityManagerTests: XCTestCase {

    var activityManager: ActivityManager!

    override func setUp() {
        super.setUp()
        activityManager = ActivityManager()
    }

    override func tearDown() {
        activityManager = nil
        super.tearDown()
    }

    // Test: Když mám nastaveno běhání (Run) a přepnu na Námořní míle (Nautical),
    // měl by se automaticky změnit typ aktivity na Plavání (Swim).
    func testValidateActivityType_SwitchesToSwim_WhenNauticalSelected() {
        // 1. Arrange (Příprava)
        activityManager.selectedActivity = .run
        let nauticalUnit = DistanceUnit.nautical

        // 2. Act (Akce)
        activityManager.validateActivityType(for: nauticalUnit)

        // 3. Assert (Ověření)
        XCTAssertEqual(activityManager.selectedActivity, .swim, "Aktivita se měla změnit na Swimming, protože Running není vodní aktivita.")
    }

    // Test: Když mám nastaveno Běhání a mám Metrické jednotky,
    // aktivita by měla zůstat Běhání.
    func testValidateActivityType_KeepsRun_WhenMetricSelected() {
        // 1. Arrange
        activityManager.selectedActivity = .run
        let metricUnit = DistanceUnit.metric

        // 2. Act
        activityManager.validateActivityType(for: metricUnit)

        // 3. Assert
        XCTAssertEqual(activityManager.selectedActivity, .run, "Aktivita měla zůstat Running.")
    }
}