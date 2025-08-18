//
//  Neon-CasinoUILaunchTests.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 7/3/23.
//

import XCTest

final class NeonCasinoUILaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    // Verifies that main UI controls are present on launch
    func testLaunchHasKeyElements() throws {
        let app = XCUIApplication()
        app.launch()

        // Spin button should be present
        let spinButton = app.buttons["spinButton"]
        XCTAssertTrue(spinButton.waitForExistence(timeout: 2), "Spin button should exist on launch")

        // Money and jackpot labels should be visible
        let moneyLabel = app.staticTexts["moneyValueLabel"]
        XCTAssertTrue(moneyLabel.waitForExistence(timeout: 2), "Money label should exist on launch")
        XCTAssertTrue(moneyLabel.label.hasPrefix("$"))

        let jackpotLabel = app.staticTexts["jackpotValueLabel"]
        XCTAssertTrue(jackpotLabel.waitForExistence(timeout: 2), "Jackpot label should exist on launch")
        XCTAssertTrue(jackpotLabel.label.hasPrefix("$"))
    }
}
