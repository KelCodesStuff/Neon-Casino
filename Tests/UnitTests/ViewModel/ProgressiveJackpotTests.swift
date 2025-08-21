//
//  ProgressiveJackpotTests.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 8/19/25.
//

//  Purpose: Verifies Verifies progressive jackpot behavior.
import XCTest
@testable import Neon_Casino

final class ProgressiveJackpotTests: XCTestCase {
    override func setUpWithError() throws { clearGameDefaults() }

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
}


