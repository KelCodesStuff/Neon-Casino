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
//  - Default strips are built from per-symbol weights, securely shuffled, and lightly sanitized to
//    avoid accidental runs of three identical symbols on a strip (which would guarantee column wins).

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
            // Shuffle securely
            var arr = bag
            var i = arr.count - 1
            while i > 0 {
                let j = Int(SecRandomCopyBytesUInt32() % UInt32(i + 1))
                arr.swapAt(i, j)
                i -= 1
            }
            // Fix runs of 3 identical in a row to avoid guaranteed column wins
            if arr.count >= 3 {
                var idx = 2
                while idx < arr.count {
                    if arr[idx] == arr[idx-1], arr[idx-1] == arr[idx-2] {
                        // Find a swap candidate that breaks the run
                        if let swapIndex = arr.indices.first(where: { k in
                            guard k != idx else { return false }
                            let prev = idx-1
                            // Ensure after swap we don't create a new triple at target or source
                            let candidate = arr[k]
                            let a = (prev-1 >= 0) ? arr[prev-1] : nil
                            let b = arr[prev]
                            // Replace arr[idx] with candidate hypothetically
                            let runBreaks = !(candidate == b && b == a)
                            return runBreaks && candidate != arr[prev]
                        }) {
                            arr.swapAt(idx, swapIndex)
                        }
                    }
                    idx += 1
                }
            }
            return arr
        }

        // Helper secure random for shuffle
        func SecRandomCopyBytesUInt32() -> UInt32 {
            var num: UInt32 = 0
            _ = SecRandomCopyBytes(kSecRandomDefault, MemoryLayout<UInt32>.size, &num)
            return num
        }

        let leftW = weights(win: 1, money: 2, jewel: 2, crown: 3, spade: 4, common: 6)
        let midW  = weights(win: 1, money: 2, jewel: 3, crown: 2, spade: 4, common: 6)
        let rightW = weights(win: 1, money: 2, jewel: 2, crown: 2, spade: 4, common: 7)
        let left = buildWeightedStrip(leftW)
        let mid = buildWeightedStrip(midW)
        let right = buildWeightedStrip(rightW)
        return [left, mid, right]
    }()

    // Secure random 32-bit value
    private func secureRandom() -> UInt32 {
        var num: UInt32 = 0
        _ = SecRandomCopyBytes(kSecRandomDefault, MemoryLayout<UInt32>.size, &num)
        return num
    }

    // Returns a 9-length array of symbol indexes (into `symbols`), row-major order.
    // Mapping columns: left(0,3,6), middle(1,4,7), right(2,5,8)
    func spin(symbols: [SymbolImages]) -> [Int] {
        var grid = Array(repeating: 0, count: 9)
        for (reelIndex, strip) in reelStrips.enumerated() {
            guard !strip.isEmpty else { continue }
            let stop = Int(secureRandom() % UInt32(strip.count))
            // Top/Mid/Bottom symbols for this reel (wrap around)
            let top = strip[stop]
            let mid = strip[(stop + 1) % strip.count]
            let bot = strip[(stop + 2) % strip.count]

            func map(_ sym: SymbolImages) -> Int {
                // Fallback to 0 if not found; symbol set should always include all used symbols
                return symbols.firstIndex(of: sym) ?? 0
            }

            switch reelIndex {
            case 0: // left column
                grid[0] = map(top)
                grid[3] = map(mid)
                grid[6] = map(bot)
            case 1: // middle column
                grid[1] = map(top)
                grid[4] = map(mid)
                grid[7] = map(bot)
            case 2: // right column
                grid[2] = map(top)
                grid[5] = map(mid)
                grid[8] = map(bot)
            default:
                break
            }
        }
        return grid
    }
}


