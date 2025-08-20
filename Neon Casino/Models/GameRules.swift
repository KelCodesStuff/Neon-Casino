//
//  GameRules.swift
//  Neon Casino
//
//  Created by Kelvin Reid on 8/15/25.
//

import Foundation

/// Pure game rules engine to allow unit testing without SwiftUI state.
///
/// Responsibilities:
/// - Defines all winning line combinations (rows, columns, diagonals)
/// - Encapsulates payout amounts for symbols (including default payout)
/// - Evaluates a 3x3 reel grid to determine payouts, jackpot, and bonus activation
///
/// Notes:
/// - Jackpot: all nine cells show the win symbol. No line payouts are added when jackpot triggers
/// - Bonus: a three-in-a-row of question symbols activates a bonus (no payout for that line)
struct GameRules {
    /// All winning line combinations across a 3x3 grid
    static let winningCombinations: [[Int]] = [
        // Rows
        [0, 1, 2],  // Top row
        [3, 4, 5],  // Middle row
        [6, 7, 8],  // Bottom row
        // Columns
        [0, 3, 6],  // Left column
        [1, 4, 7],  // Middle column
        [2, 5, 8],  // Right column
        // Diagonals
        [0, 4, 8],  // Diagonal TL-BR
        [2, 4, 6]   // Diagonal TR-BL
    ]

    /// Base payouts for three-in-a-row lines by symbol
    /// (Lines not listed here receive the default payout of 25.)
    static let payouts: [SymbolImages: Int] = [
        .moneySymbol: 500,
        .jewelSymbol: 400,
        .crownSymbol: 300,
        .spadeSymbol: 200,
        .winSymbol: 50
    ]

    /// Evaluate a 3x3 reel layout for wins, jackpot, and bonus activation.
    /// - Parameters:
    ///   - reels: 9-length array of symbol indexes (0..<(symbols.count))
    ///   - symbols: Mapping from symbol index to `SymbolImages`
    /// - Returns: Tuple with:
    ///   - totalPayout: sum of base payouts for all winning lines (excludes jackpot amount)
    ///   - transferJackpot: true iff a jackpot is triggered (all nine win symbols)
    ///   - bonusActivated: true iff a three-in-a-row of question symbols is present
    ///   - winningLineIndexes: flattened list of indexes (0..8) that participated in any winning line
    static func evaluate(reels: [Int], symbols: [SymbolImages]) -> (totalPayout: Int, transferJackpot: Bool, bonusActivated: Bool, winningLineIndexes: [Int]) {
        var totalPayout = 0
        var transferJackpot = false
        var bonusActivated = false
        var winningLineIndexes: [Int] = []

        // Jackpot: all nine cells are win symbol
        let allWin = reels.allSatisfy { idx in symbols[idx] == .winSymbol }
        if allWin {
            transferJackpot = true
            // Do not accumulate line payouts when jackpot is triggered
            return (totalPayout, transferJackpot, bonusActivated, winningLineIndexes)
        }

        // Otherwise, evaluate each winning line
        for combo in winningCombinations {
            let a = reels[combo[0]]
            let b = reels[combo[1]]
            let c = reels[combo[2]]
            if a == b && b == c {
                let symbol = symbols[a]
                if symbol == .questionSymbol {
                    bonusActivated = true
                    // no payout for question combos per spec
                    winningLineIndexes.append(contentsOf: combo)
                } else {
                    let payout = payouts[symbol] ?? 25 // default payout for any other symbol
                    totalPayout += payout
                    winningLineIndexes.append(contentsOf: combo)
                }
            }
        }

        return (totalPayout, transferJackpot, bonusActivated, winningLineIndexes)
    }
}


