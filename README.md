# Neon Casino

Neon Casino is a modern, SwiftUI-based slot machine game with a progressive jackpot, neon visuals, and a focus on testability.

[![Build and Test](https://github.com/KelCodesStuff/Neon-Casino/actions/workflows/ios-ci.yml/badge.svg)](https://github.com/KelCodesStuff/Neon-Casino/actions/workflows/ios-ci.yml)
![Platforms](https://img.shields.io/badge/Platform%20Compatibility-iOS%2016+%20|%20iPadOS%2016+-red?logo=apple&?color=red)
[![TestFlight](https://img.shields.io/badge/Join%20The%20TestFlight-blue)](https://testflight.apple.com/join/)

## Gameplay Overview

### Core Mechanics
- **Progressive Jackpot**: Starts at $100,000 and increases by 10% of your bet on each non-jackpot spin. When won, it resets to $100,000.
- **Winning Lines**: Three-in-a-row combinations (rows, columns, diagonals) trigger payouts
- **Visual Feedback**: Winning lines flash with green borders and alerts display payouts
- **Bonus Round**: Three question symbols in a row activate a special bonus alert (Bonus round to be implemented)

### Symbol Payouts
**High-Value Symbols:**
- Money: x200
- Seven: x150  
- Bar: x120

**Medium-Value Symbols:**
- Win: x40
- Jewel: x40
- Crown: x40

**Card Symbols:**
- Spade: x20
- Club: x20
- Diamond: x20
- Heart: x20

**Lucky Symbols:**
- Star: x4
- Clover: x4
- Horseshoe: x4
- Bell: x4

**Fruit Symbols:**
- Cherry: x2
- Fruit: x2
- Grapes: x2
- Lemon: x2
- Strawberry: x2
- Watermelon: x2

**Special Symbols:**
- Question: Triggers bonus round

### Special Features
- **Jackpot**: All nine reels showing Win symbols awards the full progressive jackpot
- **Bonus Round**: Three question symbols in a row display "You activated the bonus round!" alert
- **RTP**: Approximately 90-95% Return to Player ratio for balanced gameplay

## Features

### Architecture
- **SwiftUI + MVVM**: `SlotMachineView` renders from `GameViewModel` (`ObservableObject`), which encapsulates rules, state, and persistence
- **Pure Rules Engine**: `GameRules` is a stateless evaluator that enables deterministic unit testing
- **Separation of Concerns**: Game logic, UI, and data persistence are cleanly separated

### Fairness & Security
- **Cryptographically Secure RNG**: `ReelRandomizer` uses `SecRandomCopyBytes` with fallback to `SystemRandomNumberGenerator` for casino-grade fairness
- **Realistic Slot Mechanics**: Weighted reel strips with secure random stops, preventing prediction or manipulation
- **Transparent Payouts**: Complete pay table visible in Info view shows all symbol values

## Technical Highlights

### Testing Architecture
- **Comprehensive Unit Tests**: Organized by feature (GameRules, ViewModel, Jackpot, Payouts, Bonus)
- **RTP Simulation**: Monte Carlo testing with 100,000 spins to validate Return to Player percentages
- **UI Test Automation**: Page Object Model with deterministic test modes for reliable UI testing
- **Bonus Feature Testing**: Dedicated tests for bonus round activation and alert display
- **Force Modes**: Deterministic test scenarios (jackpot, bonus, wins, losses) for consistent UI testing
- **Full Coverage**: Tests for all win patterns, jackpot mechanics, bonus features, and edge cases

## Building
- Xcode 15+, iOS 16+ recommended
- Open `Neon-Casino.xcodeproj` and run the `Neon-Casino` scheme

## Preview
<div align="center">
  <h3>Screenshots</h3>
  <table>
    <tr>
      <td><img src="Images/launch-screen.png" alt="Launch Screen" width="300"></td>
      <td><img src="Images/main-screen.png" alt="Main Screen" width="300"></td>
    </tr>
    <tr>
      <td><img src="Images/info-screen.png" alt="Info Screen" width="300"></td>
      <td><img src="Images/game-over.png" alt="Game Over" width="300"></td>
    </tr>
  </table>
  <br/>
  <h3>Video</h3>
  <a href="https://youtube.com/shorts/3fkjIISIKW8" target="_blank">
    <img src="https://i.ytimg.com/vi/3fkjIISIKW8/hqdefault.jpg" alt="YouTube Video" width="560">
  </a>
  <br/>
  <br/>
</div>

## License
Neon Casino is available under the MIT license. See the `LICENSE.md` file for more info.

## Acknowledgements
 
