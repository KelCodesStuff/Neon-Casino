//
//  NeonCasinoUnitTests.swift
//  NeonCasino UnitTests
//
//  Created by Kelvin Reid on 7/3/23.
//

import XCTest
@testable import Neon_Casino

final class NeonCasinoUnitTests: XCTestCase {

    override func setUpWithError() throws {
        // Ensure a clean baseline for persisted values used by the app logic
        UserDefaults.standard.removeObject(forKey: "Jackpot")
        UserDefaults.standard.removeObject(forKey: "BetAmount")
    }

    override func tearDownWithError() throws {
        // Clean up any persisted changes from tests
        UserDefaults.standard.removeObject(forKey: "Jackpot")
        UserDefaults.standard.removeObject(forKey: "BetAmount")
    }

    func testEvaluateThreeMoneySymbolsTopRowPays500() throws {
        let symbols: [SymbolImages] = [.barSymbol, .moneySymbol, .winSymbol]
        // Build reels where top row are all moneySymbol indices (1), others arbitrary
        let reels = [1, 1, 1, 0, 2, 0, 2, 0, 2]
        let result = GameRules.evaluate(reels: reels, symbols: symbols)
        XCTAssertEqual(result.totalPayout, 500)
        XCTAssertFalse(result.transferJackpot)
    }

    func testEvaluateThreeWinSymbolsTransfersJackpot() throws {
        let symbols: [SymbolImages] = [.winSymbol, .moneySymbol]
        // Ensure ONLY the top row wins (avoid additional 3-of-a-kind)
        let reels = [
            0, 0, 0,  // jackpot line
            1, 0, 1,  // break middle row
            1, 0, 1   // break bottom row and diagonals
        ]
        let result = GameRules.evaluate(reels: reels, symbols: symbols)
        XCTAssertEqual(result.totalPayout, 0)
        XCTAssertTrue(result.transferJackpot)
    }

    func testEvaluateNoThreeOfAKindIsLoss() throws {
        let symbols: [SymbolImages] = [.barSymbol, .moneySymbol]
        let reels = [0, 1, 0, 1, 0, 1, 0, 1, 0]
        let result = GameRules.evaluate(reels: reels, symbols: symbols)
        XCTAssertEqual(result.totalPayout, 0)
        XCTAssertFalse(result.transferJackpot)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    // MARK: - Progressive Jackpot Tests

    func testJackpotIncrementsByTenPercentOfBet() throws {
        // Given a known baseline jackpot and bet amount
        UserDefaults.standard.set(100_000, forKey: GameViewModel.Keys.jackpot)
        let model = GameViewModel()
        model.setBetAmount(50)

        // When
        model.incrementJackpotForSpin(skipIfJackpotWon: false)

        // Then
        let persisted = UserDefaults.standard.integer(forKey: GameViewModel.Keys.jackpot)
        XCTAssertEqual(persisted, 100_005)
        XCTAssertEqual(model.jackpot, 100_005)
    }

    func testJackpotResetsToDefaultAfterWin() throws {
        // Given a grown jackpot and forced jackpot spin
        let defaultJackpot = 100_000
        UserDefaults.standard.set(150_000, forKey: GameViewModel.Keys.jackpot)

        let model = GameViewModel()
        // Force jackpot line directly
        if let winIndex = model.symbols.firstIndex(of: .winSymbol) {
            let x = (winIndex + 1) % model.symbols.count
            let y = (winIndex + 2) % model.symbols.count
            let reels = [winIndex, winIndex, winIndex, x, y, x, y, x, y]
            model.forceReels(reels)
        }

        // When
        let moneyBefore = model.money
        let result = model.checkWinning()

        // Then jackpot should reset to default
        let persisted = UserDefaults.standard.integer(forKey: GameViewModel.Keys.jackpot)
        XCTAssertEqual(persisted, defaultJackpot)
        XCTAssertEqual(model.jackpot, defaultJackpot)
        // And player's money increased by the awarded jackpot (150,000)
        XCTAssertEqual(model.money, moneyBefore + 150_000)
        XCTAssertTrue(result.transferJackpot)
        XCTAssertEqual(result.awardedJackpot, 150_000)
    }

    func testJackpotNeverBelowDefault() throws {
        // Given an invalid low jackpot stored
        UserDefaults.standard.set(0, forKey: GameViewModel.Keys.jackpot)
        let model = GameViewModel()
        model.setBetAmount(5)

        // When
        model.incrementJackpotForSpin(skipIfJackpotWon: false)

        // Then
        let persisted = UserDefaults.standard.integer(forKey: GameViewModel.Keys.jackpot)
        XCTAssertEqual(persisted, 100_000)
        XCTAssertEqual(model.jackpot, 100_000)
    }
}
