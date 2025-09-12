//
//  SlotMachinePage.swift
//  UITest Page Objects
//
//  Created by Kelvin Reid on 8/19/25.
//

import XCTest

// Encapsulates locators and actions for the Slot Machine screen to keep UI tests readable and maintainable (Page Object Model)
struct SlotMachinePage {
    let app: XCUIApplication

    // Buttons
    var spinButton: XCUIElement { app.buttons["spinButton"] }
    var betButton5: XCUIElement { app.buttons["betButton5"] }
    var betButton10: XCUIElement { app.buttons["betButton10"] }
    var betButton25: XCUIElement { app.buttons["betButton25"] }
    var betButton50: XCUIElement { app.buttons["betButton50"] }
    var infoButton: XCUIElement { app.buttons["infoButton"] }
    
    // Labels
    var moneyLabel: XCUIElement { app.staticTexts["moneyValueLabel"] }
    var jackpotLabel: XCUIElement { app.staticTexts["jackpotValueLabel"] }

    // Alerts
    var jackpotAlert: XCUIElement { app.alerts["Jackpot!"] }
    var winAlert: XCUIElement { app.alerts["Congratulations!"] }
    var bonusAlert: XCUIElement { app.alerts["Bonus Round!"] }
    var gameOverAlert: XCUIElement { app.alerts["Game Over"] }

    // Actions
    func launch(with env: [String: String] = [:]) {
        for (k, v) in env { app.launchEnvironment[k] = v }
        app.launch()
    }

    func tapSpin() {
        XCTAssertTrue(spinButton.waitForExistence(timeout: 2))
        spinButton.tap()
    }
}


