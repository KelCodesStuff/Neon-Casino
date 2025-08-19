//
//  ViewModelPayoutTests.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 8/19/25.
//

//  Purpose: Verifies view-model awardedWin equals payout × bet and reporting is correct.
import XCTest
@testable import Neon_Casino

final class ViewModelPayoutTests: XCTestCase {
    override func setUpWithError() throws { clearGameDefaults() }

    func testAwardedWinIsPayoutTimesBet() throws {
        let model = GameViewModel()
        model.setBetAmount(10)
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


