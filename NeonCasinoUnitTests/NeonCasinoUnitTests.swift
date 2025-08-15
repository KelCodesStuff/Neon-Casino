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
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
        UserDefaults.standard.set(100_000, forKey: "Jackpot")
        var sut = SlotMachineView()
        sut.setBetAmount(50) // 10% => 5

        // When
        sut.incrementJackpotForSpin()

        // Then
        let persisted = UserDefaults.standard.integer(forKey: "Jackpot")
        XCTAssertEqual(persisted, 100_005)
    }

    func testJackpotResetsToDefaultAfterWin() throws {
        // Given a grown jackpot and forced jackpot spin
        let defaultJackpot = 100_000
        UserDefaults.standard.set(150_000, forKey: "Jackpot")

        var sut = SlotMachineView()
        // Force jackpot line directly (no reliance on env snapshot)
        if let winIndex = sut.symbols.firstIndex(of: .winSymbol) {
            let x = (winIndex + 1) % sut.symbols.count
            let y = (winIndex + 2) % sut.symbols.count
            let reels = [winIndex, winIndex, winIndex, x, y, x, y, x, y]
            sut.forceReelsForTesting(reels)
        }

        // When
        sut.checkWinning()

        // Then jackpot should reset to default
        let persisted = UserDefaults.standard.integer(forKey: "Jackpot")
        XCTAssertEqual(persisted, defaultJackpot)
    }

    func testJackpotNeverBelowDefault() throws {
        // Given an invalid low jackpot stored
        UserDefaults.standard.set(0, forKey: "Jackpot")
        var sut = SlotMachineView()
        sut.setBetAmount(5) // 10% => 1 (rounded)

        // When
        sut.incrementJackpotForSpin()

        // Then
        let persisted = UserDefaults.standard.integer(forKey: "Jackpot")
        XCTAssertEqual(persisted, 100_000)
    }
}
