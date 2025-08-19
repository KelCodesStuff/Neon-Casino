//
//  LaunchTests.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 8/19/25.
//

//  Purpose: Smoke test that verifies key UI elements exist on app launch.
import XCTest

final class LaunchTests: XCTestCase {
    func testLaunchHasKeyElements() throws {
        let app = XCUIApplication()
        app.launch()

        let spinButton = app.buttons["spinButton"]
        XCTAssertTrue(spinButton.waitForExistence(timeout: 2))

        let moneyLabel = app.staticTexts["moneyValueLabel"]
        XCTAssertTrue(moneyLabel.waitForExistence(timeout: 2))
        XCTAssertTrue(moneyLabel.label.hasPrefix("$"))

        let jackpotLabel = app.staticTexts["jackpotValueLabel"]
        XCTAssertTrue(jackpotLabel.waitForExistence(timeout: 2))
        XCTAssertTrue(jackpotLabel.label.hasPrefix("$"))
    }
}


