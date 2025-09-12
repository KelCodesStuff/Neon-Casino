//
//  HorizontalWinTests.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 8/19/25.
//

import XCTest

// Verifies that a horizontal win (top row) shows the win alert
final class HorizontalWinTests: XCTestCase {
    func testHorizontalThreeInARowShowsWinAlert() throws {
        let app = XCUIApplication()
        let page = SlotMachinePage(app: app)
        page.launch(with: ["UITEST_FORCE": "win_horizontal"]) 
        page.tapSpin()

        XCTAssertTrue(page.winAlert.waitForExistence(timeout: 5))
        page.winAlert.buttons["OK"].tap()
    }
}


