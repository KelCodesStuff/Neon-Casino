//
//  Neon-CasinoUnitTests.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 7/3/23.
//

import XCTest
@testable import Neon_Casino

final class NeonCasinoUnitTests: XCTestCase {

    override func setUpWithError() throws {
        // Ensure persisted values start from a clean state per test
        UserDefaults.standard.removeObject(forKey: GameViewModel.Keys.jackpot)
        UserDefaults.standard.removeObject(forKey: GameViewModel.Keys.betAmount)
        UserDefaults.standard.removeObject(forKey: GameViewModel.Keys.highScore)
    }

    // MARK: - GameRules evaluation tests
    func testJackpot_AllNineWinSymbols_TransfersJackpot() throws {
        let syms: [SymbolImages] = [.winSymbol]
        // Build reels: all entries point to index 0 (winSymbol in syms)
        let reels = Array(repeating: 0, count: 9)
        let result = GameRules.evaluate(reels: reels, symbols: syms)

        XCTAssertTrue(result.transferJackpot)
        XCTAssertEqual(result.totalPayout, 0)
        XCTAssertFalse(result.bonusActivated)
    }

    func testLinePayout_MoneySymbol_TopRow_500() throws {
        let syms: [SymbolImages] = [.barSymbol, .moneySymbol]
        // Top row = moneySymbol index 1; ensure no other three-in-a-row
        let reels = [1,1,1, 0,0,1, 0,1,0]
        let result = GameRules.evaluate(reels: reels, symbols: syms)
        XCTAssertEqual(result.totalPayout, 500)
        XCTAssertFalse(result.transferJackpot)
    }

    func testLinePayout_Jewel_Diagonal_400() throws {
        let syms: [SymbolImages] = [.jewelSymbol, .barSymbol]
        // Diagonal top left -> bottom right = jewel index 0
        let reels = [0,1,1, 1,0,1, 1,1,0]
        let result = GameRules.evaluate(reels: reels, symbols: syms)
        XCTAssertEqual(result.totalPayout, 400)
        XCTAssertFalse(result.transferJackpot)
    }

    func testLinePayout_Crown_Column_300() throws {
        let syms: [SymbolImages] = [.crownSymbol, .barSymbol]
        // Column (0,3,6) = crown index 0; ensure no other three-in-a-row
        let reels = [0,1,1, 0,1,0, 0,0,1]
        let result = GameRules.evaluate(reels: reels, symbols: syms)
        XCTAssertEqual(result.totalPayout, 300)
    }

    func testLinePayout_Spade_Row_200() throws {
        let syms: [SymbolImages] = [.barSymbol, .spadeSymbol]
        // Only top row spade wins; ensure no other three-in-a-row
        let reels = [1,1,1, 0,0,1, 0,1,0]
        let result = GameRules.evaluate(reels: reels, symbols: syms)
        XCTAssertEqual(result.totalPayout, 200)
    }

    // MARK: - GameViewModel integration tests
    func testJackpot_AwardsAndResets() throws {
        UserDefaults.standard.set(150_000, forKey: GameViewModel.Keys.jackpot)
        let model = GameViewModel()
        // Force jackpot: all nine win symbols
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

    func testJackpotIncrementsByTenPercentOfBet() throws {
        UserDefaults.standard.set(100_000, forKey: GameViewModel.Keys.jackpot)
        let model = GameViewModel()
        model.setBetAmount(50) // +5
        model.incrementJackpotForSpin(skipIfJackpotWon: false)
        XCTAssertEqual(model.jackpot, 100_005)
        XCTAssertEqual(UserDefaults.standard.integer(forKey: GameViewModel.Keys.jackpot), 100_005)
    }

    func testJackpotNeverBelowDefault() throws {
        UserDefaults.standard.set(0, forKey: GameViewModel.Keys.jackpot)
        let model = GameViewModel()
        model.setBetAmount(5)
        model.incrementJackpotForSpin(skipIfJackpotWon: false)
        XCTAssertEqual(model.jackpot, model.defaultJackpot)
    }

    func testAwardedWinIsPayoutTimesBet() throws {
        let model = GameViewModel()
        model.setBetAmount(10)
        // Force a money line win (base 500) on top row
        if let moneyIdx = model.symbols.firstIndex(of: .moneySymbol) {
            let x = (moneyIdx + 1) % model.symbols.count
            let y = (moneyIdx + 2) % model.symbols.count
            model.forceReels([moneyIdx, moneyIdx, moneyIdx, x, y, x, y, x, y])
        }
        let result = model.checkWinning()
        XCTAssertEqual(result.payout, 500)
        XCTAssertEqual(result.awardedWin, 500 * 10)
    }
}


