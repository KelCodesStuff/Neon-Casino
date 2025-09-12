//
//  DiagonalWinTests.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 8/19/25.
//

import XCTest

// Verifies that a diagonal win (top left to bottom right) shows the win alert
final class DiagonalWinTests: XCTestCase {
    func testDiagonalTopLeftToBottomRightShowsWinAlert() throws {
        let app = XCUIApplication()
        let page = SlotMachinePage(app: app)
        page.launch(with: ["UITEST_FORCE": "win_diag_tlbr"]) 
        page.tapSpin()

        XCTAssertTrue(page.winAlert.waitForExistence(timeout: 5))
        page.winAlert.buttons["OK"].tap()
    }

    // Verifies that a diagonal win (top right to bottom left) shows the win alert
    func testDiagonalTopRightToBottomLeftShowsWinAlert() throws {
        let app = XCUIApplication()
        let page = SlotMachinePage(app: app)
        page.launch(with: ["UITEST_FORCE": "win_diag_trbl"]) 
        page.tapSpin()

        XCTAssertTrue(page.winAlert.waitForExistence(timeout: 5))
        page.winAlert.buttons["OK"].tap()
    }
}


