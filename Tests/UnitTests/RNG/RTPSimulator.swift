//
//  RTPSimulator.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 8/19/25.
//

import XCTest
@testable import Neon_Casino

// Simple Monte Carlo to estimate RTP given current reel strips and rules
// Not a formal statistical test, intended to help tune strip compositions
final class RTPSimulator: XCTestCase {
    func testEstimateRTP_100kSpins() throws {
        
        // Keep iterations low in CI; increase locally for better precision
        let iterations = 100_000
        let model = GameViewModel()
        model.setBetAmount(5)
        var totalBet = 0
        var totalReturn = 0

        // Simulate spins and track total bet and return
        for _ in 0..<iterations {
            model.spinReels(forceMode: nil)
            let result = model.checkWinning()
            totalBet += model.betAmount
            totalReturn += result.awardedWin + result.awardedJackpot
        }

        // Calculate RTP percentage
        let rtp = Double(totalReturn) / Double(totalBet)
        let rtpPercentage = rtp * 100
        // Print for developer insight; avoid strict asserts to prevent CI flakes
        print("Estimated RTP over \(iterations) spins: \(String(format: "%.1f", rtpPercentage))%")
    }
}


