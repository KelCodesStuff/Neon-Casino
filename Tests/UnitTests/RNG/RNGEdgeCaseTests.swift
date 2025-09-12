//
//  RNGEdgeCaseTests.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 8/19/25.
//

import XCTest
@testable import Neon_Casino

final class RNGEdgeCaseTests: XCTestCase {
    
    // Verify the ReelRandomizer class handles empty reel strips correctly
    func testEmptyReelStrips() throws {
        // Test behavior with empty reel strips
        let emptyStrips: [[SymbolImages]] = [[], [], []]
        let randomizer = ReelRandomizer(reelStrips: emptyStrips)
        let symbols: [SymbolImages] = [.barSymbol, .bellSymbol, .cherrySymbol]
        
        let grid = randomizer.spin(symbols: symbols)
        
        // Should still return a 9-element grid, but with default values
        XCTAssertEqual(grid.count, 9)
        
        // All positions should be 0 (first symbol) since strips are empty
        for index in grid {
            XCTAssertEqual(index, 0)
        }
    }
    
    // Verify the ReelRandomizer class handles reel strips containing only one symbol each correctly
    func testSingleSymbolReelStrips() throws {
        // Test behavior with reel strips containing only one symbol each
        let singleSymbolStrips: [[SymbolImages]] = [
            [.winSymbol],      // Left reel: only win symbol
            [.moneySymbol],    // Middle reel: only money symbol
            [.cherrySymbol]    // Right reel: only cherry symbol
        ]
        
        let randomizer = ReelRandomizer(reelStrips: singleSymbolStrips)
        let symbols: [SymbolImages] = [.barSymbol, .bellSymbol, .cherrySymbol, .moneySymbol, .winSymbol]
        
        let grid = randomizer.spin(symbols: symbols)
        
        XCTAssertEqual(grid.count, 9)
        
        // Find indices for our symbols
        let winIndex = symbols.firstIndex(of: .winSymbol) ?? 0
        let moneyIndex = symbols.firstIndex(of: .moneySymbol) ?? 0
        let cherryIndex = symbols.firstIndex(of: .cherrySymbol) ?? 0
        
        // Verify grid mapping:
        // Left reel (positions 0, 3, 6) should all be win symbols
        XCTAssertEqual(grid[0], winIndex)     // Top left
        XCTAssertEqual(grid[3], winIndex)     // Middle left
        XCTAssertEqual(grid[6], winIndex)     // Bottom left
        
        // Middle reel (positions 1, 4, 7) should all be money symbols
        XCTAssertEqual(grid[1], moneyIndex)   // Top middle
        XCTAssertEqual(grid[4], moneyIndex)   // Center
        XCTAssertEqual(grid[7], moneyIndex)   // Bottom middle
        
        // Right reel (positions 2, 5, 8) should all be cherry symbols
        XCTAssertEqual(grid[2], cherryIndex)  // Top right
        XCTAssertEqual(grid[5], cherryIndex)  // Middle right
        XCTAssertEqual(grid[8], cherryIndex)  // Bottom right
    }
    
    // Verify the ReelRandomizer class handles reel strips with different lengths correctly
    func testReelStripsWithDifferentLengths() throws {
        // Test behavior when reel strips have different lengths
        let differentLengthStrips: [[SymbolImages]] = [
            [.winSymbol, .moneySymbol],                    // Length 2
            [.jewelSymbol, .crownSymbol, .spadeSymbol],    // Length 3
            [.cherrySymbol]                                // Length 1
        ]
        
        let randomizer = ReelRandomizer(reelStrips: differentLengthStrips)
        let symbols: [SymbolImages] = [.barSymbol, .bellSymbol, .cherrySymbol, .moneySymbol, .winSymbol, .jewelSymbol, .crownSymbol, .spadeSymbol]
        
        let grid = randomizer.spin(symbols: symbols)
        
        XCTAssertEqual(grid.count, 9)
        
        // Find indices for our symbols
        let winIndex = symbols.firstIndex(of: .winSymbol) ?? 0
        let moneyIndex = symbols.firstIndex(of: .moneySymbol) ?? 0
        let jewelIndex = symbols.firstIndex(of: .jewelSymbol) ?? 0
        let crownIndex = symbols.firstIndex(of: .crownSymbol) ?? 0
        let spadeIndex = symbols.firstIndex(of: .spadeSymbol) ?? 0
        let cherryIndex = symbols.firstIndex(of: .cherrySymbol) ?? 0
        
        // Verify that the grid contains valid indices
        for index in grid {
            XCTAssertTrue(index >= 0)
            XCTAssertTrue(index < symbols.count)
        }
        
        // Verify that the grid contains the expected symbols from our strips
        let gridSymbols = grid.map { symbols[$0] }
        XCTAssertTrue(gridSymbols.contains(.winSymbol) || gridSymbols.contains(.moneySymbol))
        XCTAssertTrue(gridSymbols.contains(.jewelSymbol) || gridSymbols.contains(.crownSymbol) || gridSymbols.contains(.spadeSymbol))
        XCTAssertTrue(gridSymbols.contains(.cherrySymbol))
    }
    
    // Verify the ReelRandomizer class produces different results over multiple spins
    func testMultipleSpinsProduceDifferentResults() throws {
        let randomizer = ReelRandomizer()
        let symbols: [SymbolImages] = [.barSymbol, .bellSymbol, .cherrySymbol, .cloverSymbol, .clubSymbol, .crownSymbol, .diamondSymbol, .fruitSymbol, .grapesSymbol, .heartSymbol, .horseshoeSymbol, .jewelSymbol, .lemonSymbol, .moneySymbol, .questionSymbol, .sevenSymbol, .spadeSymbol, .starSymbol, .strawberrySymbol, .watermelonSymbol, .winSymbol]
        
        let spinCount = 100
        var grids: [[Int]] = []
        
        // Perform multiple spins
        for _ in 0..<spinCount {
            let grid = randomizer.spin(symbols: symbols)
            grids.append(grid)
        }
        
        // Verify all grids are valid
        for (i, grid) in grids.enumerated() {
            XCTAssertEqual(grid.count, 9, "Grid \(i) should have 9 elements")
            
            for (j, index) in grid.enumerated() {
                XCTAssertTrue(index >= 0, "Grid \(i), position \(j) should be >= 0")
                XCTAssertTrue(index < symbols.count, "Grid \(i), position \(j) should be < symbols.count")
            }
        }
        
        // Verify that we got different results (not all identical)
        let uniqueGrids = Set(grids.map { $0.description })
        XCTAssertGreaterThan(uniqueGrids.count, 1, "Should produce different grid results")
    }
}
