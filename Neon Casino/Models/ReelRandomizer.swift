//
//  ReelRandomizer.swift
//  Neon Casino
//
//  Created by Kelvin Reid on 8/19/25.

//
//  How it works:
//  - Each reel (left/middle/right) has an ordered array of symbols. Symbols appear
//    multiple times on a strip to weight their probability (more entries = more likely).
//  - On spin, we draw a secure random stop index per reel and take the three symbols starting at
//    that stop (wrapping around) as the top/middle/bottom for that reel.
//  - The three reels form a 3x3 grid by placing each reel's top/middle/bottom into the left,
//    middle, and right columns respectively. The UI then evaluates rows/columns/diagonals for wins.
//  - Default strips are built from per-symbol weights and securely shuffled using Swift's
//    cryptographically secure random number generator.

import Foundation
import Security

struct ReelRandomizer {
    // Three physical/virtual reel strips, left to right
    let reelStrips: [[SymbolImages]]

    init(reelStrips: [[SymbolImages]] = ReelRandomizer.defaultStrips) {
        self.reelStrips = reelStrips
    }

    // Default strips: tune frequencies by repeating symbols.
    // Heavier repetition = more likely. Rare (e.g., winSymbol) appears few times.
    // Each strip can be different to shape odds.
    static let defaultStrips: [[SymbolImages]] = {
        // Weights per symbol (counts per strip); higher number = more frequent
        func weights(win: Int, money: Int, jewel: Int, crown: Int, spade: Int, common: Int) -> [SymbolImages: Int] {
            var dict: [SymbolImages: Int] = [
                .winSymbol: win,
                .moneySymbol: money,
                .jewelSymbol: jewel,
                .crownSymbol: crown,
                .spadeSymbol: spade
            ]
            let commons: [SymbolImages] = [.cherrySymbol, .barSymbol, .clubSymbol, .heartSymbol, .watermelonSymbol, .grapesSymbol, .lemonSymbol, .strawberrySymbol]
            for sym in commons { dict[sym] = common }
            return dict
        }

        func buildWeightedStrip(_ w: [SymbolImages: Int]) -> [SymbolImages] {
            // Build token bag
            var bag: [SymbolImages] = []
            for (sym, count) in w where count > 0 { bag += Array(repeating: sym, count: count) }
            // Shuffle using Swift's cryptographically secure shuffle
            return bag.shuffled()
        }

        let leftW = weights(win: 1, money: 2, jewel: 2, crown: 3, spade: 4, common: 6)
        let midW  = weights(win: 1, money: 2, jewel: 3, crown: 2, spade: 4, common: 6)
        let rightW = weights(win: 1, money: 2, jewel: 2, crown: 2, spade: 4, common: 7)
        let left = buildWeightedStrip(leftW)
        let mid = buildWeightedStrip(midW)
        let right = buildWeightedStrip(rightW)
        return [left, mid, right]
    }()

    // Returns a 9-length array of symbol indexes (into `symbols`), row-major order.
    // Mapping columns: left(0,3,6), middle(1,4,7), right(2,5,8)
    func spin(symbols: [SymbolImages]) -> [Int] {
        var grid = Array(repeating: 0, count: 9)
        for (reelIndex, strip) in reelStrips.enumerated() {
            guard !strip.isEmpty else { continue }
            let stop = Int.random(in: 0..<strip.count)
            // Top/Mid/Bottom symbols for this reel (wrap around)
            let top = strip[stop]
            let mid = strip[(stop + 1) % strip.count]
            let bot = strip[(stop + 2) % strip.count]

            func map(_ sym: SymbolImages) -> Int {
                guard let index = symbols.firstIndex(of: sym) else {
                    // This should never happen if reel strips only contain symbols from the symbols array
                    assertionFailure("Symbol \(sym) not found in symbols array. Check reel strip configuration.")
                    return 0
                }
                return index
            }

            // Assign symbols to grid using pattern: reelIndex, reelIndex + 3, reelIndex + 6
            grid[reelIndex] = map(top)     // top row
            grid[reelIndex + 3] = map(mid) // middle row
            grid[reelIndex + 6] = map(bot) // bottom row
        }
        return grid
    }
}


