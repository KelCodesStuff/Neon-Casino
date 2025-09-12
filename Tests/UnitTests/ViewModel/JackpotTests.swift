//
//  JackpotTests.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 8/19/25.
//

import XCTest
@testable import Neon_Casino

final class JackpotTests: XCTestCase {
    override func setUpWithError() throws { clearGameDefaults() }

    // Verify the jackpot awards and resets
    func testJackpot_AwardsAndResets() throws {
        UserDefaults.standard.set(150_000, forKey: GameViewModel.Keys.jackpot)
        let model = GameViewModel()
        if let winIdx = model.symbols.firstIndex(of: .winSymbol) {
            model.forceReels(Array(repeating: winIdx, count: 9))
        }
        let moneyBefore = model.money
        let result = model.checkWinning()
        XCTAssertTrue(result.transferJackpot)
        XCTAssertEqual(model.jackpot, model.defaultJackpot)
        XCTAssertEqual(model.money, moneyBefore + 150_000)
        XCTAssertEqual(result.awardedJackpot, 150_000)
        XCTAssertEqual(result.winningLineIndexes.count, 9)
    }
}


