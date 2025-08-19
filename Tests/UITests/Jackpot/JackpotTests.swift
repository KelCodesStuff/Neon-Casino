//
//  JackpotTests.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 8/19/25.
//

//  Purpose: Verifies that the jackpot trigger (all nine win symbols) shows the jackpot alert.
import XCTest

final class JackpotTests: XCTestCase {
    func testJackpotWinTransfersJackpot() throws {
        let app = XCUIApplication()
        let page = SlotMachinePage(app: app)
        page.launch(with: ["UITEST_FORCE": "jackpot"]) 
        page.tapSpin()

        XCTAssertTrue(page.jackpotAlert.waitForExistence(timeout: 2))
        page.jackpotAlert.buttons["OK"].tap()
    }
}


