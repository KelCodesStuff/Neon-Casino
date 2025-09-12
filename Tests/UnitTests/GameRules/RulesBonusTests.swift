//
//  RulesBonusTests.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 8/19/25.
//

import XCTest
@testable import Neon_Casino

final class RulesBonusTests: XCTestCase {
    override func setUpWithError() throws { clearGameDefaults() }

    // Verify that three question symbols activate the bonus alert
    func testQuestionSymbol_ThreeInARow_ActivatesBonus() throws {
        let syms: [SymbolImages] = [.questionSymbol, .barSymbol]
        let reels = [0,0,0, 1,1,0, 1,0,1]
        let result = GameRules.evaluate(reels: reels, symbols: syms)
        XCTAssertTrue(result.bonusActivated)
        XCTAssertEqual(result.totalPayout, 0)
        XCTAssertEqual(result.winningLineIndexes, [0,1,2])
    }
}


