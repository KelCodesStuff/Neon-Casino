//
//  RulesPayoutTests.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 8/19/25.
//

import XCTest
@testable import Neon_Casino

final class RulesPayoutTests: XCTestCase {
    override func setUpWithError() throws { clearGameDefaults() }

    // MARK: - Helper Methods
    
    // Creates a 3x3 reel grid from three rows
    private func createReelGrid(topRow: [Int], middleRow: [Int], bottomRow: [Int]) -> [Int] {
        return topRow + middleRow + bottomRow
    }
    
    // Tests a specific symbol payout with assertions
    private func testSymbolPayout(
        symbol: SymbolImages,
        otherSymbol: SymbolImages,
        reels: [Int],
        expectedPayout: Int,
        expectedLineIndexes: [Int],
        testName: String
    ) throws {
        let symbols: [SymbolImages] = [otherSymbol, symbol]
        let result = GameRules.evaluate(reels: reels, symbols: symbols)
        
        XCTAssertEqual(result.totalPayout, expectedPayout, 
                      "\(testName): Payout should be \(expectedPayout)")
        XCTAssertFalse(result.transferJackpot, 
                      "\(testName): Should not transfer jackpot")
        XCTAssertFalse(result.bonusActivated, 
                      "\(testName): Should not activate bonus")
        XCTAssertEqual(result.winningLineIndexes, expectedLineIndexes, 
                      "\(testName): Winning line indexes should match")
    }

    // MARK: - Money Symbol Tests
    
    func testMoneySymbol_TopRow() throws {
        let reels = createReelGrid(
            topRow:    [1, 1, 1],      // Money symbols in top row
            middleRow: [0, 0, 1],   // Mixed symbols
            bottomRow: [0, 1, 0]    // Mixed symbols
        )
        
        try testSymbolPayout(
            symbol: .moneySymbol,
            otherSymbol: .barSymbol,
            reels: reels,
            expectedPayout: 200,
            expectedLineIndexes: [0, 1, 2], // Top row
            testName: "Money Symbol Top Row"
        )
    }
    
    func testMoneySymbol_MiddleRow() throws {
        let reels = createReelGrid(
            topRow:    [0, 0, 1],      // Mixed symbols
            middleRow: [1, 1, 1],   // Money symbols in middle row
            bottomRow: [0, 1, 0]    // Mixed symbols
        )
        
        try testSymbolPayout(
            symbol: .moneySymbol,
            otherSymbol: .barSymbol,
            reels: reels,
            expectedPayout: 200,
            expectedLineIndexes: [3, 4, 5], // Middle row
            testName: "Money Symbol Middle Row"
        )
    }
    
    func testMoneySymbol_BottomRow() throws {
        let reels = createReelGrid(
            topRow:    [0, 1, 0],      // Mixed symbols
            middleRow: [0, 0, 1],   // Mixed symbols
            bottomRow: [1, 1, 1]    // Money symbols in bottom row
        )
        
        try testSymbolPayout(
            symbol: .moneySymbol,
            otherSymbol: .barSymbol,
            reels: reels,
            expectedPayout: 200,
            expectedLineIndexes: [6, 7, 8], // Bottom row
            testName: "Money Symbol Bottom Row"
        )
    }

    // MARK: - Jewel Symbol Tests
    
    func testJewelSymbol_Diagonal() throws {
        let reels = createReelGrid(
            topRow:    [1, 0, 0],      // Jewel in top-left
            middleRow: [0, 1, 0],   // Jewel in center
            bottomRow: [0, 0, 1]    // Jewel in bottom-right
        )
        
        try testSymbolPayout(
            symbol: .jewelSymbol,
            otherSymbol: .barSymbol,
            reels: reels,
            expectedPayout: 40,
            expectedLineIndexes: [0, 4, 8], // Diagonal TL->BR
            testName: "Jewel Symbol Diagonal"
        )
    }
    
    func testJewelSymbol_Column() throws {
        let reels = createReelGrid(
            topRow:    [0, 1, 0],      // Jewel in top-middle
            middleRow: [1, 1, 0],   // Jewel in center
            bottomRow: [0, 1, 1]    // Jewel in bottom-middle
        )
        
        try testSymbolPayout(
            symbol: .jewelSymbol,
            otherSymbol: .barSymbol,
            reels: reels,
            expectedPayout: 40,
            expectedLineIndexes: [1, 4, 7], // Middle column
            testName: "Jewel Symbol Column"
        )
    }

    // MARK: - Crown Symbol Tests
    
    func testCrownSymbol_Column() throws {
        let reels = createReelGrid(
            topRow:    [1, 1, 0],      // Crown in top-left
            middleRow: [1, 0, 0],   // Crown in center
            bottomRow: [1, 0, 1]    // Crown in bottom-left
        )
        
        try testSymbolPayout(
            symbol: .crownSymbol,
            otherSymbol: .barSymbol,
            reels: reels,
            expectedPayout: 40,
            expectedLineIndexes: [0, 3, 6], // Left column
            testName: "Crown Symbol Column"
        )
    }

    // MARK: - Spade Symbol Tests
    
    func testSpadeSymbol_Row() throws {
        let reels = createReelGrid(
            topRow:    [1, 1, 1],      // Spade symbols in top row
            middleRow: [0, 0, 1],   // Mixed symbols
            bottomRow: [0, 1, 0]    // Mixed symbols
        )
        
        try testSymbolPayout(
            symbol: .spadeSymbol,
            otherSymbol: .barSymbol,
            reels: reels,
            expectedPayout: 20,
            expectedLineIndexes: [0, 1, 2], // Top row
            testName: "Spade Symbol Row"
        )
    }

    // MARK: - Cherry Symbol Tests
    
    func testCherrySymbol_Row() throws {
        let reels = createReelGrid(
            topRow:    [0, 1, 0],      // Mixed symbols
            middleRow: [1, 1, 1],   // Cherry symbols in middle row
            bottomRow: [1, 0, 1]    // Mixed symbols
        )
        
        try testSymbolPayout(
            symbol: .cherrySymbol,
            otherSymbol: .barSymbol,
            reels: reels,
            expectedPayout: 2,
            expectedLineIndexes: [3, 4, 5], // Middle row
            testName: "Cherry Symbol Row"
        )
    }

    // MARK: - Edge Case Tests
    
    // Verify no winning lines results in 0 payout
    func testNoWinningLines() throws {
        let reels = createReelGrid(
            topRow:    [0, 1, 0],      // No three in a row
            middleRow: [0, 1, 1],   // No three in a row
            bottomRow: [1, 0, 0]    // No three in a row
        )
        
        let symbols: [SymbolImages] = [.barSymbol, .moneySymbol]
        let result = GameRules.evaluate(reels: reels, symbols: symbols)
        
        XCTAssertEqual(result.totalPayout, 0, "No winning lines should result in 0 payout")
        XCTAssertFalse(result.transferJackpot, "No jackpot transfer for no wins")
        XCTAssertFalse(result.bonusActivated, "No bonus activation for no wins")
        XCTAssertTrue(result.winningLineIndexes.isEmpty, "No winning line indexes for no wins")
    }
    
    // Verify multiple winning lines results in payout
    func testMultipleWinningLines() throws {
        // Create a scenario with exactly 2 winning lines (no overlapping wins)
        let reels = createReelGrid(
            topRow:    [1, 1, 1],      // Top row win
            middleRow: [1, 1, 1],   // Middle row win
            bottomRow: [0, 0, 2]    // Bottom row different (no win, no column overlap)
        )
        
        let symbols: [SymbolImages] = [.barSymbol, .moneySymbol, .jewelSymbol]
        let result = GameRules.evaluate(reels: reels, symbols: symbols)
        
        // Should detect both winning lines
        XCTAssertEqual(result.totalPayout, 400, "Multiple winning lines should result in a combined payout of 400")
        XCTAssertFalse(result.transferJackpot, "Multiple wins should not transfer jackpot")
        XCTAssertFalse(result.bonusActivated, "Multiple wins should not activate bonus")
        XCTAssertEqual(result.winningLineIndexes.count, 6, "Should detect 6 winning positions (2 rows)")
    }
    
    // Verify diagonal wins results in payout
    func testDiagonalWins() throws {
        // Test both diagonal directions
        let reelsTLBR = createReelGrid(
            topRow:    [1, 0, 0],      // Top-left
            middleRow: [0, 1, 0],   // Center
            bottomRow: [0, 0, 1]    // Bottom-right
        )
        
        let symbols: [SymbolImages] = [.barSymbol, .moneySymbol]
        let resultTLBR = GameRules.evaluate(reels: reelsTLBR, symbols: symbols)
        
        XCTAssertEqual(resultTLBR.totalPayout, 200, "Diagonal Top Left -> Bottom Right should pay 200")
        XCTAssertEqual(resultTLBR.winningLineIndexes, [0, 4, 8], "Should detect diagonal Top Left -> Bottom Right")
        
        // Test TR->BL diagonal
        let reelsTRBL = createReelGrid(
            topRow:    [0, 0, 1],      // Top-right
            middleRow: [0, 1, 0],   // Center
            bottomRow: [1, 0, 0]    // Bottom-left
        )
        
        let resultTRBL = GameRules.evaluate(reels: reelsTRBL, symbols: symbols)
        
        XCTAssertEqual(resultTRBL.totalPayout, 200, "Diagonal Top Right -> Bottom Left should pay 200")
        XCTAssertEqual(resultTRBL.winningLineIndexes, [2, 4, 6], "Should detect diagonal Top Right -> Bottom Left")
    }
}


 
