# Neon Casino

[![Build and Test](https://github.com/KelCodesStuff/Neon-Casino/actions/workflows/ios-ci.yml/badge.svg)](https://github.com/KelCodesStuff/Neon-Casino/actions/workflows/ios-ci.yml)

[![TestFlight](https://img.shields.io/badge/Join%20The%20TestFlight-blue)](https://testflight.apple.com/join/)

![Platforms](https://img.shields.io/badge/Platform%20Compatibility-iOS%2016+%20|%20iPadOS%2016+-red?logo=apple&?color=red)

##

Neon Casino is a modern, SwiftUI-based slot machine game with a progressive jackpot, neon visuals, and a focus on testability.

## Gameplay overview
- Progressive jackpot: Starts at $100,000 and increases by 10% of your bet on each non-jackpot spin. When won, it resets to $100,000.
- Wins: Three-in-a-row (rows, columns, diagonals) pay based on symbol:
  - Money: $500
  - Jewel: $400
  - Crown: $300
  - Spade: $200
  - Win: $50
  - Any other symbol: $25
- Jackpot: All nine reels show the Win symbol. The full jackpot amount is added to your current money.
- Visual feedback: Winning lines flash and alert displays payouts.

## Features
- **SwiftUI + MVVM**: `SlotMachineView` renders from `GameViewModel` (`ObservableObject`), which encapsulates rules, state, and persistence.
- **Rules Engine**: `GameRules` is a pure evaluator for deterministic unit tests.
- **Cryptographically Secure RNG**: `ReelRandomizer` uses `SecRandomCopyBytes` with fallback to `SystemRandomNumberGenerator` for casino-grade fairness.
- **Realistic slot mechanics**: Weighted reel strips with secure random stops, preventing prediction or manipulation.
- **Persistence**: `UserDefaults` stores jackpot, bet, and high score.
- **Comprehensive testing**: Organized unit and UI tests by feature, with Page Object Model for UI tests.

## Technical Highlights

### Cryptographically Secure Random Number Generation
- **Primary**: Uses `SecRandomCopyBytes` for cryptographically secure randomness
- **Fallback**: Gracefully degrades to `SystemRandomNumberGenerator` if secure RNG fails
- **Performance**: Optimized with symbol-to-index dictionary for O(1) lookups
- **Fairness**: Prevents prediction or manipulation of outcomes

### Testing Architecture
- **Unit tests**: Organized by feature (GameRules, ViewModel, Jackpot, Payouts)
- **UI tests**: Page Object Model with deterministic test modes
- **Coverage**: Tests for all win patterns, jackpot mechanics, and edge cases

## Building
- Xcode 15+, iOS 16+ recommended
- Open `Neon-Casino.xcodeproj` and run the `Neon-Casino` scheme

## Images

Here are some screenshots of Neon Casino in action:

<div align="center">
  <img src="Images/launch-screen.png" alt="launch-screen" width="300">
  <img src="Images/main-screen.png" alt="main-screen" width="300">
  <img src="Images/info-screen.png" alt="info-screen" width="300">
  <img src="Images/game-over.png" alt="game-over" width="300">
</div>

## License
Neon Casino is available under the MIT license. See the `LICENSE.md` file for more info.

## Acknowledgements
 
