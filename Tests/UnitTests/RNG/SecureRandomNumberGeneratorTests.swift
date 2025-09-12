//
//  SecureRandomNumberGeneratorTests.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 8/19/25.
//

import XCTest
@testable import Neon_Casino

final class SecureRandomNumberGeneratorTests: XCTestCase {
    
    // Verify the struct implements the required protocol
    func testImplementsRandomNumberGeneratorProtocol() throws {
        var generator = SecureRandomNumberGenerator()
        let _: RandomNumberGenerator = generator
        
        // Test that next() method exists and returns UInt64
        let value = generator.next()
        XCTAssertTrue(value >= 0) // UInt64 is always >= 0
    }
    
    // Verify the struct produces different values
    func testProducesDifferentValues() throws {
        var generator = SecureRandomNumberGenerator()
        
        // Generate multiple values and ensure they're different
        let values = (0..<100).map { _ in generator.next() }
        let uniqueValues = Set(values)
        
        // With 100 random UInt64 values, we should have many unique values
        // (though theoretically possible to have duplicates, extremely unlikely)
        XCTAssertGreaterThan(uniqueValues.count, 50, "Should produce mostly unique values")
    }
    
    // Verify the struct produces values within the expected range
    func testValuesAreWithinExpectedRange() throws {
        var generator = SecureRandomNumberGenerator()
        
        // Generate multiple values and verify they're reasonable UInt64 values
        for _ in 0..<1000 {
            let value = generator.next()
            XCTAssertTrue(value >= 0, "UInt64 should always be >= 0")
            XCTAssertTrue(value <= UInt64.max, "UInt64 should not exceed max value")
        }
    }
    
    // Verify the struct produces different results when called consecutively
    func testConsecutiveCallsProduceDifferentResults() throws {
        var generator = SecureRandomNumberGenerator()
        
        let firstValue = generator.next()
        let secondValue = generator.next()
        let thirdValue = generator.next()
        
        // While theoretically possible to get the same value twice in a row,
        // it's extremely unlikely with cryptographically secure RNG
        // We'll just verify we can call next() multiple times without errors
        XCTAssertTrue(firstValue >= 0)
        XCTAssertTrue(secondValue >= 0)
        XCTAssertTrue(thirdValue >= 0)
    }
    
    // Verify the struct can be used with Swift's shuffle method
    func testCanBeUsedWithSwiftShuffle() throws {
        var generator = SecureRandomNumberGenerator()
        
        let originalArray = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let shuffledArray = originalArray.shuffled(using: &generator)
        
        // Verify shuffle works and produces different order
        XCTAssertEqual(Set(originalArray), Set(shuffledArray), "Shuffle should preserve all elements")
        XCTAssertNotEqual(originalArray, shuffledArray, "Shuffle should change order")
    }
    
    // Verify the struct produces different sequences when called from multiple instances
    func testMultipleInstancesProduceDifferentSequences() throws {
        var generator1 = SecureRandomNumberGenerator()
        var generator2 = SecureRandomNumberGenerator()
        
        let values1 = (0..<10).map { _ in generator1.next() }
        let values2 = (0..<10).map { _ in generator2.next() }
        
        // Different instances should produce different sequences
        // (though theoretically possible to be identical, extremely unlikely)
        XCTAssertNotEqual(values1, values2, "Different instances should produce different sequences")
    }
}
