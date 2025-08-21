//
//  BonusTests.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 8/21/25.
//

//  Purpose: Verifies that the bonus trigger (three question symbols in a row) shows the bonus alert with correct message.
import XCTest

final class BonusTests: XCTestCase {
    func testBonusRound_ShowsCorrectAlert() throws {
        let app = XCUIApplication()
        let page = SlotMachinePage(app: app)
        page.launch(with: ["UITEST_FORCE": "bonus"]) 
        page.tapSpin()

        // Wait for bonus alert to appear
        XCTAssertTrue(page.bonusAlert.waitForExistence(timeout: 5))
        
        // Verify the alert has the correct title and message
        XCTAssertEqual(page.bonusAlert.staticTexts.element(boundBy: 0).label, "Bonus Round!")
        XCTAssertEqual(page.bonusAlert.staticTexts.element(boundBy: 1).label, "You activated the bonus round!")
        
        // Dismiss the alert
        page.bonusAlert.buttons["OK"].tap()
    }
}
