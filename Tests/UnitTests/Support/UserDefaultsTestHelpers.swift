//
//  UserDefaultsTestHelpers.swift
//  Neon-Casino
//
//  Created by Kelvin Reid on 8/19/25.
//

//  Purpose: Common helpers to reset persisted state between unit tests.
import Foundation
@testable import Neon_Casino

func clearGameDefaults() {
    UserDefaults.standard.removeObject(forKey: GameViewModel.Keys.jackpot)
    UserDefaults.standard.removeObject(forKey: GameViewModel.Keys.betAmount)
    UserDefaults.standard.removeObject(forKey: GameViewModel.Keys.highScore)
}


