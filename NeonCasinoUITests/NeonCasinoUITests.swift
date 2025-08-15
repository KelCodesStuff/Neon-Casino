//
//  NeonCasinoUITests.swift
//  NeonCasino UITests
//
//  Created by Kelvin Reid on 7/3/23.
//

import XCTest

final class NeonCasinoUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWinningSpinUpdatesMoneyAndShowsAlert() throws {
        let app = XCUIApplication(bundleIdentifier: "com.Studio757.NeonSlots")
        app.launchEnvironment["UITEST_FORCE"] = "win_money"
        app.launch()

        let spin = app.buttons["spinButton"]
        XCTAssertTrue(spin.waitForExistence(timeout: 2))
        spin.tap()

        // Dismiss win alert
        let winAlert = app.alerts["Congratulations!"]
        XCTAssertTrue(winAlert.waitForExistence(timeout: 3))
        winAlert.buttons["OK"].tap()

        let moneyLabel = app.staticTexts["moneyValueLabel"]
        XCTAssertTrue(moneyLabel.waitForExistence(timeout: 2))
        XCTAssertEqual(moneyLabel.label, "$2600")
    }

    func testJackpotWinTransfersJackpot() throws {
        let app = XCUIApplication(bundleIdentifier: "com.Studio757.NeonSlots")
        app.launchEnvironment["UITEST_FORCE"] = "jackpot"
        app.launch()

        let spin = app.buttons["spinButton"]
        XCTAssertTrue(spin.waitForExistence(timeout: 2))
        spin.tap()

        // Alert should appear with Jackpot title
        let jackpotAlert = app.alerts["Jackpot!"]
        XCTAssertTrue(jackpotAlert.waitForExistence(timeout: 2))
        jackpotAlert.buttons["OK"].tap()
    }

    func testLosingSpinDecrementsMoney() throws {
        let app = XCUIApplication(bundleIdentifier: "com.Studio757.NeonSlots")
        app.launchEnvironment["UITEST_FORCE"] = "loss"
        app.launch()

        let spin = app.buttons["spinButton"]
        XCTAssertTrue(spin.waitForExistence(timeout: 2))
        spin.tap()

        let moneyLabel = app.staticTexts["moneyValueLabel"]
        XCTAssertTrue(moneyLabel.waitForExistence(timeout: 2))
        XCTAssertEqual(moneyLabel.label, "$95")
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
