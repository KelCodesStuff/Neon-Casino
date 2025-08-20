//
//  GameOverTests.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 8/19/25.
//

//  Purpose: Verifies that forcing game over shows the game over alert.
import XCTest

final class GameOverTests: XCTestCase {
    func testForceGameOverShowsAlert() throws {
        let app = XCUIApplication()
        let page = SlotMachinePage(app: app)
        page.launch(with: ["UITEST_FORCE": "game_over"]) 
        page.tapSpin()

        XCTAssertTrue(page.gameOverAlert.waitForExistence(timeout: 5))
        page.gameOverAlert.buttons["OK"].tap()
    }
}


