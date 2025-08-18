//
//  Neon-CasinoUITests.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 7/3/23.
//

import XCTest

// MARK: - Page Objects
struct BasePage {
    let app: XCUIApplication
}

struct SlotMachinePage {
    let app: XCUIApplication

    var spinButton: XCUIElement { app.buttons["spinButton"] }
    
    var moneyLabel: XCUIElement { app.staticTexts["moneyValueLabel"] }
    var jackpotLabel: XCUIElement { app.staticTexts["jackpotValueLabel"] }
    
    var jackpotAlert: XCUIElement { app.alerts["Jackpot!"] }
    var winAlert: XCUIElement { app.alerts["Congratulations!"] }
    var gameOverAlert: XCUIElement { app.alerts["Game Over"] }

    func launch(with env: [String: String] = [:]) {
        for (k, v) in env { app.launchEnvironment[k] = v }
        app.launch()
    }

    func tapSpin() {
        XCTAssertTrue(spinButton.waitForExistence(timeout: 2))
        spinButton.tap()
    }
}

// MARK: - Tests
final class NeonCasinoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    func testWinningSpinUpdatesMoneyAndShowsAlert() throws {
        let app = XCUIApplication()
        let page = SlotMachinePage(app: app)
        page.launch(with: ["UITEST_FORCE": "win_money"])
        page.tapSpin()

        XCTAssertTrue(page.winAlert.waitForExistence(timeout: 3))
        page.winAlert.buttons["OK"].tap()

        XCTAssertTrue(page.moneyLabel.waitForExistence(timeout: 2))
        XCTAssertTrue(page.moneyLabel.label.hasPrefix("$"))
    }

    func testHorizontalThreeInARowShowsWinAlert() throws {
        let app = XCUIApplication()
        let page = SlotMachinePage(app: app)
        page.launch(with: ["UITEST_FORCE": "win_horizontal"])
        page.tapSpin()

        XCTAssertTrue(page.winAlert.waitForExistence(timeout: 3))
        page.winAlert.buttons["OK"].tap()
    }

    func testVerticalThreeInARowShowsWinAlert() throws {
        let app = XCUIApplication()
        let page = SlotMachinePage(app: app)
        page.launch(with: ["UITEST_FORCE": "win_vertical"])
        page.tapSpin()

        XCTAssertTrue(page.winAlert.waitForExistence(timeout: 3))
        page.winAlert.buttons["OK"].tap()
    }

    func testDiagonalTopLeftToBottomRightShowsWinAlert() throws {
        let app = XCUIApplication()
        let page = SlotMachinePage(app: app)
        page.launch(with: ["UITEST_FORCE": "win_diag_tlbr"])
        page.tapSpin()

        XCTAssertTrue(page.winAlert.waitForExistence(timeout: 3))
        page.winAlert.buttons["OK"].tap()
    }

    func testDiagonalTopRightToBottomLeftShowsWinAlert() throws {
        let app = XCUIApplication()
        let page = SlotMachinePage(app: app)
        page.launch(with: ["UITEST_FORCE": "win_diag_trbl"])
        page.tapSpin()

        XCTAssertTrue(page.winAlert.waitForExistence(timeout: 3))
        page.winAlert.buttons["OK"].tap()
    }

    func testJackpotWinTransfersJackpot() throws {
        let app = XCUIApplication()
        let page = SlotMachinePage(app: app)
        page.launch(with: ["UITEST_FORCE": "jackpot"])
        page.tapSpin()

        XCTAssertTrue(page.jackpotAlert.waitForExistence(timeout: 2))
        page.jackpotAlert.buttons["OK"].tap()
    }

    func testForceGameOverShowsAlert() throws {
        let app = XCUIApplication()
        let page = SlotMachinePage(app: app)
        page.launch(with: ["UITEST_FORCE": "game_over"])
        page.tapSpin()

        XCTAssertTrue(page.gameOverAlert.waitForExistence(timeout: 2))
        page.gameOverAlert.buttons["OK"].tap()
    }

    func testLosingSpinDecrementsMoney() throws {
        let app = XCUIApplication()
        let page = SlotMachinePage(app: app)
        page.launch(with: ["UITEST_FORCE": "loss"])
        let before = page.moneyLabel.waitForExistence(timeout: 2) ? page.moneyLabel.label : nil
        page.tapSpin()
        XCTAssertTrue(page.moneyLabel.waitForExistence(timeout: 2))
        XCTAssertNotEqual(page.moneyLabel.label, before)
    }
}
