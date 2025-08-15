//
//  GameRules.swift
//  Neon Casino
//
//  Created by AI Assistant on 8/15/25.
//

import Foundation

/// Pure game rules engine to allow unit testing without SwiftUI state.
struct GameRules {
    static let winningCombinations: [[Int]] = [
        [0, 1, 2],  // Top row
        [3, 4, 5],  // Middle row
        [6, 7, 8],  // Bottom row
        [0, 4, 8],  // Diagonal TL-BR
        [2, 4, 6]   // Diagonal TR-BL
    ]

    static let payouts: [SymbolImages: Int] = [
        .moneySymbol: 500,
        .jewelSymbol: 400,
        .crownSymbol: 300,
        .spadeSymbol: 200
    ]

    /// Evaluate the reels and return total payout and whether jackpot should transfer.
    /// - Parameters:
    ///   - reels: 9-length array of symbol indices corresponding to `symbols`.
    ///   - symbols: The ordered list of available symbols.
    static func evaluate(reels: [Int], symbols: [SymbolImages]) -> (totalPayout: Int, transferJackpot: Bool) {
        var totalPayout = 0
        var transferJackpot = false

        for combo in winningCombinations {
            let a = reels[combo[0]]
            let b = reels[combo[1]]
            let c = reels[combo[2]]
            if a == b && b == c {
                let symbol = symbols[a]
                if symbol == .winSymbol {
                    transferJackpot = true
                } else if let payout = payouts[symbol] {
                    totalPayout += payout
                }
            }
        }

        return (totalPayout, transferJackpot)
    }
}


