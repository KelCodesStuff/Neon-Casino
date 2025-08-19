//
//  GameRulesPayoutTests.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 8/19/25.
//

//  Purpose: Verifies line payout amounts for money, jewel, crown, spade, and default cases.
import XCTest
@testable import Neon_Casino

final class GameRulesPayoutTests: XCTestCase {
    override func setUpWithError() throws { clearGameDefaults() }

    func testMoney_TopRow_500() throws {
        let syms: [SymbolImages] = [.barSymbol, .moneySymbol]
        let reels = [1,1,1, 0,0,1, 0,1,0]
        let result = GameRules.evaluate(reels: reels, symbols: syms)
        XCTAssertEqual(result.totalPayout, 500)
        XCTAssertFalse(result.transferJackpot)
    }

    func testJewel_Diagonal_400() throws {
        let syms: [SymbolImages] = [.jewelSymbol, .barSymbol]
        let reels = [0,1,1, 1,0,1, 1,1,0]
        let result = GameRules.evaluate(reels: reels, symbols: syms)
        XCTAssertEqual(result.totalPayout, 400)
    }

    func testCrown_Column_300() throws {
        let syms: [SymbolImages] = [.crownSymbol, .barSymbol]
        let reels = [0,1,1, 0,1,0, 0,0,1]
        let result = GameRules.evaluate(reels: reels, symbols: syms)
        XCTAssertEqual(result.totalPayout, 300)
    }

    func testSpade_Row_200() throws {
        let syms: [SymbolImages] = [.barSymbol, .spadeSymbol]
        let reels = [1,1,1, 0,0,1, 0,1,0]
        let result = GameRules.evaluate(reels: reels, symbols: syms)
        XCTAssertEqual(result.totalPayout, 200)
    }

    func testDefault_OtherSymbol_Row_50() throws {
        let syms: [SymbolImages] = [.cherrySymbol, .barSymbol]
        let reels = [0,0,0, 1,1,0, 1,0,1]
        let result = GameRules.evaluate(reels: reels, symbols: syms)
        XCTAssertEqual(result.totalPayout, 50)
    }
}


