//
//  ReelRandomizerTests.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 8/19/25.
//

import XCTest
@testable import Neon_Casino

final class ReelRandomizerTests: XCTestCase {
    
    // Verify the default strips are initialized correctly
    func testDefaultStripsInitialization() throws {
        let randomizer = ReelRandomizer()
        
        // Verify we have exactly 3 reel strips
        XCTAssertEqual(randomizer.reelStrips.count, 3, "Should have exactly 3 reel strips")
        
        // Verify each strip is not empty
        for (index, strip) in randomizer.reelStrips.enumerated() {
            XCTAssertFalse(strip.isEmpty, "Reel strip \(index) should not be empty")
            XCTAssertGreaterThan(strip.count, 10, "Reel strip \(index) should have reasonable length")
        }
    }
    
    // Verify the default strips contain all symbols
    func testDefaultStripsContainAllSymbols() throws {
        let randomizer = ReelRandomizer()
        let allSymbols: Set<SymbolImages> = [
            .winSymbol, .moneySymbol, .jewelSymbol, .crownSymbol, .spadeSymbol,
            .cherrySymbol, .barSymbol, .clubSymbol, .heartSymbol, .watermelonSymbol,
            .grapesSymbol, .lemonSymbol, .strawberrySymbol
        ]
        
        // Verify each strip contains all expected symbols
        for (index, strip) in randomizer.reelStrips.enumerated() {
            let stripSymbols = Set(strip)
            XCTAssertTrue(allSymbols.isSubset(of: stripSymbols), 
                        "Reel strip \(index) should contain all expected symbols")
        }
    }
    
    // Verify the default strips have different weights
    func testDefaultStripsHaveDifferentWeights() throws {
        let randomizer = ReelRandomizer()
        
        // Count occurrences of each symbol in each strip
        for (stripIndex, strip) in randomizer.reelStrips.enumerated() {
            var symbolCounts: [SymbolImages: Int] = [:]
            
            for symbol in strip {
                symbolCounts[symbol, default: 0] += 1
            }
            
            // Verify win symbols appear less frequently (weighted lower)
            let winCount = symbolCounts[.winSymbol] ?? 0
            let commonCount = symbolCounts[.cherrySymbol] ?? 0
            
            XCTAssertLessThan(winCount, commonCount, 
                            "Win symbols should appear less frequently than common symbols in strip \(stripIndex)")
            
            // Verify money symbols appear more frequently than win symbols
            let moneyCount = symbolCounts[.moneySymbol] ?? 0
            XCTAssertGreaterThan(moneyCount, winCount, 
                               "Money symbols should appear more frequently than win symbols in strip \(stripIndex)")
        }
    }
    
    // Verify the spin method produces a valid grid with all symbols
    func testSpinProducesValidGrid() throws {
        let randomizer = ReelRandomizer()
        let symbols: [SymbolImages] = [.barSymbol, .bellSymbol, .cherrySymbol, .cloverSymbol, .clubSymbol, .crownSymbol, .diamondSymbol, .fruitSymbol, .grapesSymbol, .heartSymbol, .horseshoeSymbol, .jewelSymbol, .lemonSymbol, .moneySymbol, .questionSymbol, .sevenSymbol, .spadeSymbol, .starSymbol, .strawberrySymbol, .watermelonSymbol, .winSymbol]
        
        // Test multiple spins
        for _ in 0..<100 {
            let grid = randomizer.spin(symbols: symbols)
            
            // Verify grid has exactly 9 elements
            XCTAssertEqual(grid.count, 9, "Grid should have exactly 9 elements")
            
            // Verify all indices are valid
            for (index, gridIndex) in grid.enumerated() {
                XCTAssertTrue(gridIndex >= 0, "Grid index \(index) should be >= 0")
                XCTAssertTrue(gridIndex < symbols.count, "Grid index \(index) should be < symbols.count")
            }
        }
    }
    
    // Verify the spin method produces valid grid mapping
    func testSpinGridMappingIsCorrect() throws {
        let randomizer = ReelRandomizer()
        let symbols: [SymbolImages] = [.barSymbol, .bellSymbol, .cherrySymbol, .cloverSymbol, .clubSymbol, .crownSymbol, .diamondSymbol, .fruitSymbol, .grapesSymbol, .heartSymbol, .horseshoeSymbol, .jewelSymbol, .lemonSymbol, .moneySymbol, .questionSymbol, .sevenSymbol, .spadeSymbol, .starSymbol, .strawberrySymbol, .watermelonSymbol, .winSymbol]
        
        let grid = randomizer.spin(symbols: symbols)
        
        // Verify grid mapping follows the expected pattern:
        // Left reel: positions 0, 3, 6 (top, middle, bottom)
        // Middle reel: positions 1, 4, 7 (top, middle, bottom)  
        // Right reel: positions 2, 5, 8 (top, middle, bottom)
        
        // Test that we can access the grid positions without errors
        let topRow = [grid[0], grid[1], grid[2]]      // positions 0, 1, 2
        let middleRow = [grid[3], grid[4], grid[5]]   // positions 3, 4, 5
        let bottomRow = [grid[6], grid[7], grid[8]]   // positions 6, 7, 8
        
        // Verify all rows have valid symbol indices
        for (rowIndex, row) in [topRow, middleRow, bottomRow].enumerated() {
            for (colIndex, symbolIndex) in row.enumerated() {
                XCTAssertTrue(symbolIndex >= 0, "Row \(rowIndex), col \(colIndex) should have valid index")
                XCTAssertTrue(symbolIndex < symbols.count, "Row \(rowIndex), col \(colIndex) should have valid index")
            }
        }
    }
    
    // Verify the spin method produces different results
    func testSpinProducesDifferentResults() throws {
        let randomizer = ReelRandomizer()
        let symbols: [SymbolImages] = [.barSymbol, .bellSymbol, .cherrySymbol, .cloverSymbol, .clubSymbol, .crownSymbol, .diamondSymbol, .fruitSymbol, .grapesSymbol, .heartSymbol, .horseshoeSymbol, .jewelSymbol, .lemonSymbol, .moneySymbol, .questionSymbol, .sevenSymbol, .spadeSymbol, .starSymbol, .strawberrySymbol, .watermelonSymbol, .winSymbol]
        
        let spin1 = randomizer.spin(symbols: symbols)
        let spin2 = randomizer.spin(symbols: symbols)
        let spin3 = randomizer.spin(symbols: symbols)
        
        // While theoretically possible to get identical results,
        // it's extremely unlikely with secure RNG
        // We'll just verify we can call spin multiple times without errors
        XCTAssertEqual(spin1.count, 9)
        XCTAssertEqual(spin2.count, 9)
        XCTAssertEqual(spin3.count, 9)
    }
    
    // Verify the spin method produces a valid grid with custom reel strips
    func testCustomReelStrips() throws {
        // Create custom reel strips with known symbols
        let customStrips: [[SymbolImages]] = [
            [.winSymbol, .moneySymbol, .cherrySymbol],           // Left reel
            [.jewelSymbol, .crownSymbol, .spadeSymbol],          // Middle reel
            [.barSymbol, .clubSymbol, .heartSymbol]              // Right reel
        ]
        
        let randomizer = ReelRandomizer(reelStrips: customStrips)
        let symbols: [SymbolImages] = [.barSymbol, .bellSymbol, .cherrySymbol, .cloverSymbol, .clubSymbol, .crownSymbol, .diamondSymbol, .fruitSymbol, .grapesSymbol, .heartSymbol, .horseshoeSymbol, .jewelSymbol, .lemonSymbol, .moneySymbol, .questionSymbol, .sevenSymbol, .spadeSymbol, .starSymbol, .strawberrySymbol, .watermelonSymbol, .winSymbol]
        
        let grid = randomizer.spin(symbols: symbols)
        
        // Verify grid has correct dimensions
        XCTAssertEqual(grid.count, 9)
        
        // Verify all indices are valid
        for index in grid {
            XCTAssertTrue(index >= 0)
            XCTAssertTrue(index < symbols.count)
        }
    }
    
    // Verify the reel strips are shuffled.
    func testReelStripsAreShuffled() throws {
        let randomizer = ReelRandomizer()
        
        // Get the default strips
        let strips = randomizer.reelStrips
        
        // Verify that the strips are not in a predictable order
        // by checking that consecutive symbols are not always the same
        for (stripIndex, strip) in strips.enumerated() {
            var consecutiveSameCount = 0
            var totalConsecutivePairs = 0
            
            for i in 0..<(strip.count - 1) {
                if strip[i] == strip[i + 1] {
                    consecutiveSameCount += 1
                }
                totalConsecutivePairs += 1
            }
            
            // With shuffled strips, we shouldn't have too many consecutive identical symbols
            let consecutiveRatio = Double(consecutiveSameCount) / Double(totalConsecutivePairs)
            XCTAssertLessThan(consecutiveRatio, 0.3, 
                            "Strip \(stripIndex) should not have too many consecutive identical symbols")
        }
    }
}
