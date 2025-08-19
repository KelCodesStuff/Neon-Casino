//
//  DiagonalWinTests.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 8/19/25.
//

//  Purpose: Verifies both diagonal three-in-a-row cases trigger a win alert.
import XCTest

final class DiagonalWinTests: XCTestCase {
    func testDiagonalTopLeftToBottomRightShowsWinAlert() throws {
        let app = XCUIApplication()
        let page = SlotMachinePage(app: app)
        page.launch(with: ["UITEST_FORCE": "win_diag_tlbr"]) 
        page.tapSpin()

        XCTAssertTrue(page.winAlert.waitForExistence(timeout: 5))
        page.winAlert.buttons["OK"].tap()
    }

    func testDiagonalTopRightToBottomLeftShowsWinAlert() throws {
        let app = XCUIApplication()
        let page = SlotMachinePage(app: app)
        page.launch(with: ["UITEST_FORCE": "win_diag_trbl"]) 
        page.tapSpin()

        XCTAssertTrue(page.winAlert.waitForExistence(timeout: 5))
        page.winAlert.buttons["OK"].tap()
    }
}


