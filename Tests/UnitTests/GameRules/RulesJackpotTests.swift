//
//  RulesJackpotTests.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 8/19/25.
//

import XCTest
@testable import Neon_Casino

final class RulesJackpotTests: XCTestCase {
    override func setUpWithError() throws { clearGameDefaults() }

    // Verify that all nine win symbols trigger the jackpot
    func testJackpot_AllNineWinSymbols_TransfersJackpot() throws {
        let syms: [SymbolImages] = [.winSymbol]
        let reels = Array(repeating: 0, count: 9)
        let result = GameRules.evaluate(reels: reels, symbols: syms)
        XCTAssertTrue(result.transferJackpot)
        XCTAssertEqual(result.totalPayout, 0)
        XCTAssertFalse(result.bonusActivated)
    }
}


