//
//  RulesJackpotTests.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 8/19/25.
//

//  Purpose: Verifies jackpot conditions at the rules level (all nine win symbols).
import XCTest
@testable import Neon_Casino

final class RulesJackpotTests: XCTestCase {
    override func setUpWithError() throws { clearGameDefaults() }

    func testJackpot_AllNineWinSymbols_TransfersJackpot() throws {
        let syms: [SymbolImages] = [.winSymbol]
        let reels = Array(repeating: 0, count: 9)
        let result = GameRules.evaluate(reels: reels, symbols: syms)
        XCTAssertTrue(result.transferJackpot)
        XCTAssertEqual(result.totalPayout, 0)
        XCTAssertFalse(result.bonusActivated)
    }
}


