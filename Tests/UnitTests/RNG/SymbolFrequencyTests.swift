//
//  SymbolFrequencyTests.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 8/19/25.
//

import XCTest
@testable import Neon_Casino

final class SymbolFrequencyTests: XCTestCase {
    
    // Verify the symbol frequencies match the expected weights
    func testSymbolFrequenciesMatchExpectedWeights() throws {
        let randomizer = ReelRandomizer()
        let symbols: [SymbolImages] = [.barSymbol, .bellSymbol, .cherrySymbol, .cloverSymbol, .clubSymbol, .crownSymbol,
                                       .diamondSymbol, .fruitSymbol, .grapesSymbol, .heartSymbol, .horseshoeSymbol, .jewelSymbol,
                                       .lemonSymbol, .moneySymbol, .questionSymbol, .sevenSymbol, .spadeSymbol, .starSymbol, .strawberrySymbol,
                                       .watermelonSymbol, .winSymbol]
        
        // Expected weights per strip from ReelRandomizer.defaultStrips implementation
        let expectedWeightsPerStrip: [[SymbolImages: Int]] = [
            // Left strip: win:1, money:2, jewel:2, crown:3, spade:4, common:6
            [
                .winSymbol: 1,
                .moneySymbol: 2,
                .jewelSymbol: 2,
                .crownSymbol: 3,
                .spadeSymbol: 4,
                .cherrySymbol: 6, .barSymbol: 6, .clubSymbol: 6, .heartSymbol: 6,
                .watermelonSymbol: 6, .grapesSymbol: 6, .lemonSymbol: 6, .strawberrySymbol: 6
            ],
            // Middle strip: win:1, money:2, jewel:3, crown:2, spade:4, common:6
            [
                .winSymbol: 1,
                .moneySymbol: 2,
                .jewelSymbol: 3,
                .crownSymbol: 2,
                .spadeSymbol: 4,
                .cherrySymbol: 6, .barSymbol: 6, .clubSymbol: 6, .heartSymbol: 6,
                .watermelonSymbol: 6, .grapesSymbol: 6, .lemonSymbol: 6, .strawberrySymbol: 6
            ],
            // Right strip: win:1, money:2, jewel:2, crown:2, spade:4, common:7
            [
                .winSymbol: 1,
                .moneySymbol: 2,
                .jewelSymbol: 2,
                .crownSymbol: 2,
                .spadeSymbol: 4,
                .cherrySymbol: 7, .barSymbol: 7, .clubSymbol: 7, .heartSymbol: 7,
                .watermelonSymbol: 7, .grapesSymbol: 7, .lemonSymbol: 7, .strawberrySymbol: 7
            ]
        ]
        
        // Count actual frequencies in each strip
        for (stripIndex, strip) in randomizer.reelStrips.enumerated() {
            var actualCounts: [SymbolImages: Int] = [:]
            
            for symbol in strip {
                actualCounts[symbol, default: 0] += 1
            }
            
            // Verify that actual counts match expected weights for this strip
            let expectedWeights = expectedWeightsPerStrip[stripIndex]
            for (symbol, expectedCount) in expectedWeights {
                let actualCount = actualCounts[symbol] ?? 0
                XCTAssertEqual(actualCount, expectedCount, 
                             "Symbol \(symbol) should appear \(expectedCount) times in strip \(stripIndex)")
            }
        }
    }
    
    // Verify the rare symbols appear less frequently than the common symbols
    func testRareSymbolsAppearLessFrequently() throws {
        let randomizer = ReelRandomizer()
        let symbols: [SymbolImages] = [.barSymbol, .bellSymbol, .cherrySymbol, .cloverSymbol, .clubSymbol, .crownSymbol,
                                       .diamondSymbol, .fruitSymbol, .grapesSymbol, .heartSymbol, .horseshoeSymbol, .jewelSymbol,
                                       .lemonSymbol, .moneySymbol, .questionSymbol, .sevenSymbol, .spadeSymbol, .starSymbol, .strawberrySymbol,
                                       .watermelonSymbol, .winSymbol]
        
        // Simulate many spins to test frequency
        let spinCount = 10_000
        var symbolCounts: [SymbolImages: Int] = [:]
        
        for _ in 0..<spinCount {
            let grid = randomizer.spin(symbols: symbols)
            
            // Count symbols in the visible 3x3 grid
            for gridIndex in grid {
                let symbol = symbols[gridIndex]
                symbolCounts[symbol, default: 0] += 1
            }
        }
        
        // Verify rare symbols appear less frequently than common ones
        let winCount = symbolCounts[.winSymbol] ?? 0
        let moneyCount = symbolCounts[.moneySymbol] ?? 0
        let cherryCount = symbolCounts[.cherrySymbol] ?? 0
        
        XCTAssertLessThan(winCount, moneyCount, "Win symbols should appear less frequently than money symbols")
        XCTAssertLessThan(moneyCount, cherryCount, "Money symbols should appear less frequently than cherry symbols")
        
        // Verify the ratios are roughly in line with expected weights
        let winToMoneyRatio = Double(winCount) / Double(moneyCount)
        let expectedWinToMoneyRatio = 1.0 / 2.0 // 1:2 weight ratio
        
        // Allow for some variance due to randomness (within 50% of expected)
        let tolerance = 0.5
        XCTAssertGreaterThan(winToMoneyRatio, expectedWinToMoneyRatio * (1.0 - tolerance),
                           "Win to money ratio should be close to expected")
        XCTAssertLessThan(winToMoneyRatio, expectedWinToMoneyRatio * (1.0 + tolerance),
                         "Win to money ratio should be close to expected")
    }
    
    // Verify the symbol distribution is balanced.
    func testSymbolDistributionIsBalanced() throws {
        let randomizer = ReelRandomizer()
        let symbols: [SymbolImages] = [.barSymbol, .bellSymbol, .cherrySymbol, .cloverSymbol, .clubSymbol, .crownSymbol,
                                       .diamondSymbol, .fruitSymbol, .grapesSymbol, .heartSymbol, .horseshoeSymbol, .jewelSymbol,
                                       .lemonSymbol, .moneySymbol, .questionSymbol, .sevenSymbol, .spadeSymbol, .starSymbol, .strawberrySymbol,
                                       .watermelonSymbol, .winSymbol]
        
        // Test that symbols don't cluster in specific positions
        let spinCount = 5_000
        var positionCounts: [[SymbolImages: Int]] = Array(repeating: [:], count: 9)
        
        for _ in 0..<spinCount {
            let grid = randomizer.spin(symbols: symbols)
            
            for (position, gridIndex) in grid.enumerated() {
                let symbol = symbols[gridIndex]
                positionCounts[position][symbol, default: 0] += 1
            }
        }
        
        // Verify that no single position is dominated by one symbol
        for (position, counts) in positionCounts.enumerated() {
            let totalCount = counts.values.reduce(0, +)
            let maxCount = counts.values.max() ?? 0
            let maxPercentage = Double(maxCount) / Double(totalCount)
            
            // No single symbol should dominate more than 30% of any position
            XCTAssertLessThan(maxPercentage, 0.3, 
                            "Position \(position) should not be dominated by a single symbol")
        }
    }
    
    // Verify the reel strips are different
    func testReelStripsAreDifferent() throws {
        let randomizer = ReelRandomizer()
        let strips = randomizer.reelStrips
        
        // Verify that different reels have different symbol distributions
        // This ensures the game isn't predictable across reels
        
        for i in 0..<strips.count {
            for j in (i+1)..<strips.count {
                let strip1 = strips[i]
                let strip2 = strips[j]
                
                // Different reels should have different symbol distributions
                // We'll check that they're not identical
                XCTAssertNotEqual(strip1, strip2, "Reel strips \(i) and \(j) should be different")
                
                // They should also have different lengths or different symbol arrangements
                let differentLength = strip1.count != strip2.count
                let differentArrangement = zip(strip1, strip2).contains { $0 != $1 }
                
                XCTAssertTrue(differentLength || differentArrangement, 
                            "Reel strips \(i) and \(j) should have different characteristics")
            }
        }
    }
    
    // Verify the spin method is consistent
    func testSpinConsistency() throws {
        let randomizer = ReelRandomizer()
        let symbols: [SymbolImages] = [.barSymbol, .bellSymbol, .cherrySymbol, .cloverSymbol, .clubSymbol, .crownSymbol,
                                       .diamondSymbol, .fruitSymbol, .grapesSymbol, .heartSymbol, .horseshoeSymbol, .jewelSymbol,
                                       .lemonSymbol, .moneySymbol, .questionSymbol, .sevenSymbol, .spadeSymbol, .starSymbol, .strawberrySymbol,
                                       .watermelonSymbol, .winSymbol]
        
        // Test that spin method is consistent and doesn't crash
        let spinCount = 1_000
        
        for i in 0..<spinCount {
            let grid = randomizer.spin(symbols: symbols)
            
            // Basic validation on every spin
            XCTAssertEqual(grid.count, 9, "Spin \(i) should produce 9 elements")
            
            for (index, gridIndex) in grid.enumerated() {
                XCTAssertTrue(gridIndex >= 0, "Spin \(i), position \(index) should have valid index")
                XCTAssertTrue(gridIndex < symbols.count, "Spin \(i), position \(index) should have valid index")
            }
        }
    }
}
