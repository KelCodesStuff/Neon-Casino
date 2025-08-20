//
//  GameViewModel.swift
//  Neon Casino
//
//  Created by Kelvin Reid on 7/6/23.
//

import Foundation
import SwiftUI

/// Observable game state and orchestration of rules, persistence, and user intents.
final class GameViewModel: ObservableObject {
    /// UserDefaults keys
    enum Keys {
        static let jackpot = "Jackpot"
        static let betAmount = "BetAmount"
    }

    // MARK: - Constants
    /// Minimum jackpot value after reset
    let defaultJackpot: Int = 100_000
    /// Ordered list of available symbols. Indices in `reels` map into this array
    let symbols: [SymbolImages] = [.barSymbol, .bellSymbol, .cherrySymbol, .cloverSymbol, .clubSymbol, .crownSymbol, .diamondSymbol, .fruitSymbol, .grapesSymbol, .heartSymbol, .horseshoeSymbol, .jewelSymbol, .lemonSymbol, .moneySymbol, .questionSymbol, .sevenSymbol, .spadeSymbol, .starSymbol, .strawberrySymbol, .watermelonSymbol, .winSymbol]
    private let randomizer = ReelRandomizer()

    // MARK: - Published State
    @Published var jackpot: Int            // Progressive jackpot
    @Published var money: Int              // Player balance
    @Published var betAmount: Int          // Current bet amount
    @Published var reels: [Int]            // 9 indices into `symbols`

    // MARK: - Init
    /// Initialize game state from persistence (where applicable)
    init() {
        let storedJackpot = UserDefaults.standard.object(forKey: Keys.jackpot) as? Int ?? defaultJackpot
        let storedBet = UserDefaults.standard.integer(forKey: Keys.betAmount)

        self.jackpot = max(storedJackpot, defaultJackpot)
        self.money = 1000
        self.betAmount = storedBet > 0 ? storedBet : 5
        self.reels = Array(0..<9)
    }

    // MARK: - Intents
    /// Set the current bet amount and persist for future sessions
    func setBetAmount(_ amount: Int) {
        betAmount = amount
        UserDefaults.standard.set(amount, forKey: Keys.betAmount)
    }

    #if DEBUG
    /// Test-only: force exact reels without RNG
    func forceReels(_ values: [Int]) {
        guard values.count == 9 else { return }
        reels = values
    }
    #endif

    /// Spin reels either deterministically (for UI tests) or randomly.
    ///
    /// Outcome rules:
    /// - In normal runs: each of the 9 reel positions is assigned a random
    ///   symbol index in `0 ..< symbols.count`.
    /// - In UI tests (DEBUG): if the environment variable `UITEST_FORCE` is set,
    ///   a specific deterministic layout is produced (e.g. win_horizontal,
    ///   win_vertical, win_diag_tlbr, win_diag_trbl, jackpot, loss, etc.).
    /// This function solely determines the symbols shown after a spin; bet size
    /// only affects payout scaling and progressive jackpot increments.
    
    /// - Parameter forceMode: Optional mode to create specific reel outcomes for automation.
    func spinReels(forceMode: String? = nil) {
        #if DEBUG
        if let force = forceMode {
            if force == "win_money", let moneyIndex = symbols.firstIndex(of: .moneySymbol) {
                let x = (moneyIndex + 1) % symbols.count
                let y = (moneyIndex + 2) % symbols.count
                reels = [moneyIndex, moneyIndex, moneyIndex, x, y, x, y, x, y]
                return
            } else if force == "jackpot", let winIndex = symbols.firstIndex(of: .winSymbol) {
                // Force all nine to win symbol to trigger jackpot per new rules
                reels = Array(repeating: winIndex, count: 9)
                return
            } else if force == "win_horizontal", let moneyIndex = symbols.firstIndex(of: .moneySymbol) {
                let x = (moneyIndex + 1) % symbols.count
                let y = (moneyIndex + 2) % symbols.count
                // Top row win only
                reels = [moneyIndex, moneyIndex, moneyIndex, x, y, x, y, x, y]
                return
            } else if force == "win_vertical", let moneyIndex = symbols.firstIndex(of: .moneySymbol) {
                let x = (moneyIndex + 1) % symbols.count
                let y = (moneyIndex + 2) % symbols.count
                // First column win only (0,3,6)
                reels = [moneyIndex, x, y, moneyIndex, y, x, moneyIndex, x, y]
                return
            } else if force == "win_diag_tlbr", let moneyIndex = symbols.firstIndex(of: .moneySymbol) {
                let x = (moneyIndex + 1) % symbols.count
                let y = (moneyIndex + 2) % symbols.count
                // Diagonal TL->BR (0,4,8)
                reels = [moneyIndex, x, y, x, moneyIndex, x, y, x, moneyIndex]
                return
            } else if force == "win_diag_trbl", let moneyIndex = symbols.firstIndex(of: .moneySymbol) {
                let x = (moneyIndex + 1) % symbols.count
                let y = (moneyIndex + 2) % symbols.count
                // Diagonal TR->BL (2,4,6)
                reels = [x, y, moneyIndex, x, moneyIndex, x, moneyIndex, x, y]
                return
            } else if force == "loss" {
                reels = [0, 1, 2, 1, 2, 0, 2, 0, 1]
                return
            }
        }
        #endif

        // Normal spin: use reel strips + secure random stops to build 3x3 grid
        reels = randomizer.spin(symbols: symbols)
    }

    /// Encapsulates the outcome of a single spin evaluation
    struct WinResult {
        let payout: Int               // base payout (before bet multiplier)
        let transferJackpot: Bool
        let awardedJackpot: Int       // amount of jackpot awarded to money
        let awardedWin: Int           // payout * betAmount
        let winningLineIndexes: [Int] // indexes (0-8) of all winning cells (jackpot or regular)
    }

    /// Evaluate reels using rules and apply balance/jackpot updates.
    func checkWinning() -> WinResult {
        let eval = GameRules.evaluate(reels: reels, symbols: symbols)
        var payout = eval.totalPayout
        let transferJackpot = eval.transferJackpot
        let bonusActivated = eval.bonusActivated
        var awarded = 0
        var winningIndexes: [Int] = []

        if transferJackpot {
            awarded = jackpot
            money += awarded
            jackpot = defaultJackpot
            UserDefaults.standard.set(jackpot, forKey: Keys.jackpot)

            // All nine cells are part of jackpot
            winningIndexes = Array(0..<9)
        }

        if payout > 0 {
            let won = payout * betAmount
            money += won
            // Collect winning line indexes from eval
            winningIndexes.append(contentsOf: eval.winningLineIndexes)
        } else if !transferJackpot {
            playerLoses()
        }

        return WinResult(payout: payout,
                         transferJackpot: transferJackpot,
                         awardedJackpot: awarded,
                         awardedWin: payout * betAmount,
                         winningLineIndexes: winningIndexes)
    }

    /// Progressive jackpot increases by 10% of bet amount after each non-jackpot spin
    func incrementJackpotForSpin(skipIfJackpotWon: Bool) {
        if skipIfJackpotWon { return }
        let storedRaw = UserDefaults.standard.integer(forKey: Keys.jackpot)
        let storedBet = UserDefaults.standard.integer(forKey: Keys.betAmount)
        let betUsed = storedBet > 0 ? storedBet : betAmount
        let increment = Int(round(Double(betUsed) * 0.10))

        let newValue: Int
        if storedRaw < defaultJackpot {
            newValue = defaultJackpot
        } else {
            newValue = storedRaw + increment
        }

        jackpot = newValue
        UserDefaults.standard.set(newValue, forKey: Keys.jackpot)
    }

    /// Decrement player balance by bet amount; clamp at 0
    func playerLoses() {
        money -= betAmount
        if money < 0 { money = 0 }
    }

    /// Reset balance and bet to defaults
    func resetGame() {
        money = 1000
        setBetAmount(5)
    }
}

 
