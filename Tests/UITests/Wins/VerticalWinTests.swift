//
//  VerticalWinTests.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 8/19/25.
//

import XCTest

// Verifies that a vertical win (left column) shows the win alert
final class VerticalWinTests: XCTestCase {
    func testVerticalThreeInARowShowsWinAlert() throws {
        let app = XCUIApplication()
        let page = SlotMachinePage(app: app)
        page.launch(with: ["UITEST_FORCE": "win_vertical"]) 
        page.tapSpin()

        XCTAssertTrue(page.winAlert.waitForExistence(timeout: 5))
        page.winAlert.buttons["OK"].tap()
    }
}


