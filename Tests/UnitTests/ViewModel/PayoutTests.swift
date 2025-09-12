//
//  PayoutTests.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 8/19/25.
//

import XCTest
@testable import Neon_Casino

final class PayoutTests: XCTestCase {
    override func setUpWithError() throws { clearGameDefaults() }

    // Test data for different bet amounts
    private let betAmounts = [5, 10, 25, 50, 100]
    
    // Helper method to test payout for a specific bet amount
    private func testPayoutForBet(_ betAmount: Int) throws {
        let model = GameViewModel()
        model.setBetAmount(betAmount)
        
        // Force a winning combination (money symbol in top row)
        if let moneyIdx = model.symbols.firstIndex(of: .moneySymbol) {
            let x = (moneyIdx + 1) % model.symbols.count
            let y = (moneyIdx + 2) % model.symbols.count
            model.forceReels([moneyIdx, moneyIdx, moneyIdx, x, y, x, y, x, y])
        }
        
        let result = model.checkWinning()
        
        // Verify base payout and bet scaling
        XCTAssertEqual(result.payout, 200, "Base payout should be 200 for money symbol")
        XCTAssertEqual(result.awardedWin, 200 * betAmount, 
                      "Awarded win should be payout × bet (\(200 * betAmount))")
    }
    
    // Individual test methods for each bet amount
    func testAwardedWinIsPayoutTimesBet5() throws {
        try testPayoutForBet(5)
    }
    
    func testAwardedWinIsPayoutTimesBet10() throws {
        try testPayoutForBet(10)
    }
    
    func testAwardedWinIsPayoutTimesBet25() throws {
        try testPayoutForBet(25)
    }
    
    func testAwardedWinIsPayoutTimesBet50() throws {
        try testPayoutForBet(50)
    }
    
    func testAwardedWinIsPayoutTimesBet100() throws {
        try testPayoutForBet(100)
    }
    
    // Alternative: Single parameterized test (if you prefer)
    func testAwardedWinScalingForAllBetAmounts() throws {
        for betAmount in betAmounts {
            try testPayoutForBet(betAmount)
        }
    }
}