//
//  RTPReflector.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 8/19/25.
//

import XCTest
@testable import Neon_Casino

// Simple Monte Carlo to estimate RTP given current reel strips and rules.
// Not a formal statistical test, intended to help tune strip compositions.
final class RTPReflector: XCTestCase {
    func testEstimateRTP_10kSpins() throws {
        // Keep runs short in CI; increase locally for better precision
        let iterations = 10_000
        let model = GameViewModel()
        model.setBetAmount(10)
        var totalBet = 0
        var totalReturn = 0

        for _ in 0..<iterations {
            // Normal spin path (no UI test forcing)
            model.spinReels(forceMode: nil)
            let result = model.checkWinning()
            // Bet reduces money via loss path; for RTP we measure nominal bet and wins
            totalBet += model.betAmount
            totalReturn += result.awardedWin + result.awardedJackpot
        }

        let rtp = Double(totalReturn) / Double(totalBet)
        // Print for developer insight; avoid strict asserts to prevent CI flakes
        print("Estimated RTP over \(iterations) spins: \(rtp)")
    }
}


