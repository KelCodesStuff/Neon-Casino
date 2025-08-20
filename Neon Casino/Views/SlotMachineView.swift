//
//  SlotMachineView.swift
//  Neon Casino
//
//  Created by Kelvin Reid on 7/6/23.
//

import SwiftUI
import UIKit

struct SlotMachineView: View {
    @StateObject private var viewModel = GameViewModel()
    
    let haptics = UINotificationFeedbackGenerator()
    
    @State private var animatingSymbol = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isSpinDisabled = false
    @State private var currentSpinDuration: Double = 0.7
    @State private var flashingWinningIndexes: [Int] = []
    @State private var flashPhase: Bool = false
    @State private var isGameOver = false
    @State private var isCycling = false
    @State private var cyclingSymbols: [Int] = Array(repeating: 0, count: 9)
    @State private var stoppedReels: Set<Int> = []
    
    // MARK: - UI
    var body: some View {
        // Jackpot display
        VStack(alignment: .center, spacing: 10) {
            Text("JACKPOT")
                .modifier(JackpotLabelModifier())
            Text(currency(viewModel.jackpot))
                .modifier(ScoreNumberModifier())
                .accessibilityIdentifier("jackpotValueLabel")
        }
        Spacer()
        
        VStack(alignment: .center, spacing: 0) {
            ForEach(0..<3, id: \.self) { row in
            HStack {
                    ForEach(0..<3, id: \.self) { col in
                        let index = row * 3 + col
                ZStack {
                    ReelView()
                            Image(viewModel.symbols[isCycling ? cyclingSymbols[index] : viewModel.reels[index]].rawValue)
                        .resizable()
                        .modifier(SymbolImageModifier())
                        .opacity(animatingSymbol ? 1 : 0)
                        .offset(y: animatingSymbol ? 0 : 50)
                                .animation(.easeOut(duration: currentSpinDuration), value: animatingSymbol)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.green.opacity(flashingWinningIndexes.contains(index) ? (flashPhase ? 1.0 : 0.2) : 0), lineWidth: flashingWinningIndexes.contains(index) ? 4 : 0)
                        )
                    }
                }
            }
            Spacer()
            
            // MARK: - Money Display
            HStack {
                Text("money".uppercased())
                    .modifier(ScoreLabelModifier())
                    .multilineTextAlignment(.trailing)
                Text(currency(viewModel.money))
                    .modifier(ScoreNumberModifier())
                    .accessibilityIdentifier("moneyValueLabel")
            }
            .modifier(ScoreCapsuleModifier())
            
            Spacer()
                .frame(height: 20)
            
            // MARK: - Wager Buttons
            HStack {
                Spacer()
                
                // 5 button
                HStack(alignment: .center, spacing: 10) {
                    Button(action: {
                        viewModel.setBetAmount(5)
                        playSound(sound: "bet-chip", type: "mp3")
                        haptics.notificationOccurred(.success)
                    }) {
                        Image("5-chip")
                            .resizable()
                            .renderingMode(.original)
                            .modifier(BetButtonModifier())
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green, lineWidth: viewModel.betAmount == 5 ? 3 : 0)
                    )
                }
                Spacer()
                
                // 10 button
                HStack(alignment: .center, spacing: 10) {
                    Button(action: {
                        viewModel.setBetAmount(10)
                        playSound(sound: "bet-chip", type: "mp3")
                        haptics.notificationOccurred(.success)
                    }) {
                        Image("10-chip")
                            .resizable()
                            .renderingMode(.original)
                            .modifier(BetButtonModifier())
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green, lineWidth: viewModel.betAmount == 10 ? 3 : 0)
                    )
                }
                Spacer()
                
                // 25 button
                HStack(alignment: .center, spacing: 10) {
                    Button(action: {
                        viewModel.setBetAmount(25)
                        playSound(sound: "bet-chip", type: "mp3")
                        haptics.notificationOccurred(.success)
                    }) {
                        Image("25-chip")
                            .resizable()
                            .renderingMode(.original)
                            .modifier(BetButtonModifier())
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green, lineWidth: viewModel.betAmount == 25 ? 3 : 0)
                    )
                }
                Spacer()
                
                // 50 button
                HStack(alignment: .center, spacing: 10) {
                    Button(action: {
                        viewModel.setBetAmount(50)
                        playSound(sound: "bet-chip", type: "mp3")
                        haptics.notificationOccurred(.success)
                    }) {
                        Image("50-chip")
                            .resizable()
                            .renderingMode(.original)
                            .modifier(BetButtonModifier())
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green, lineWidth: viewModel.betAmount == 50 ? 3 : 0)
                    )
                }
                Spacer()
            }
            
            HStack {
                Spacer()
                // MARK: - Spin Button
                Button(action: {
                    guard !isSpinDisabled else { return }
                    isSpinDisabled = true
                    
                    // Start cycling animation
                    startCyclingAnimation()
                }) {
                    Image("spin-button-1")
                        .resizable()
                        .renderingMode(.original)
                        .modifier(SpinButtonModifier())
                }
                .accessibilityIdentifier("spinButton")
                .frame(maxWidth: .infinity)
                .disabled(isSpinDisabled)

                Spacer()
            }
        }
        // Allow natural sizing; parent view may constrain
        
        // Combined Alert
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"), action: {
                    flashingWinningIndexes.removeAll()
                    flashPhase = false
                    
                    // Reset game only when game over alert is dismissed
                    if isGameOver {
                        viewModel.resetGame()
                        isGameOver = false
                    }
                })
            )
        }
        .onAppear {
            // Ensure the reels are visible on first launch and play start sound
            animatingSymbol = true
            playSound(sound: "game-start", type: "mp3")
        }
    }

    // MARK: - Helpers
    private func currency(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
    
    private func startCyclingAnimation() {
        // Deduct bet immediately
        viewModel.money -= viewModel.betAmount
        
        // Reset animation state
        isCycling = true
        stoppedReels.removeAll()
        
        // Make symbols visible immediately for cycling
        withAnimation {
            self.animatingSymbol = true
        }
        
        // Play spin sound and haptics
        playSound(sound: "spin", type: "mp3")
        haptics.notificationOccurred(.success)
        
        // Start cycling through random symbols
        startSymbolCycling()
        
        // After 2 seconds, start stopping reels in sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.stopReelsInSequence()
        }
    }
    
    private func startSymbolCycling() {
        // Update cycling symbols with random values only for reels that haven't stopped
        for i in 0..<9 {
            if !stoppedReels.contains(i) {
                cyclingSymbols[i] = Int.random(in: 0..<viewModel.symbols.count)
            }
        }
        
        // Continue cycling every 0.1 seconds until reels start stopping
        if isCycling {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.startSymbolCycling()
            }
        }
    }
    
    private func stopReelsInSequence() {
        // Get the final result first
        var isForcedGameOver = false
        var finalReels: [Int] = []
        
        #if DEBUG
        let force = ProcessInfo.processInfo.environment["UITEST_FORCE"]
        if let force = force {
            // For UI tests, generate the forced result
            if force == "win_money", let moneyIndex = viewModel.symbols.firstIndex(of: .moneySymbol) {
                let x = (moneyIndex + 1) % viewModel.symbols.count
                let y = (moneyIndex + 2) % viewModel.symbols.count
                finalReels = [moneyIndex, moneyIndex, moneyIndex, x, y, x, y, x, y]
            } else if force == "jackpot", let winIndex = viewModel.symbols.firstIndex(of: .winSymbol) {
                finalReels = Array(repeating: winIndex, count: 9)
            } else if force == "win_horizontal", let moneyIndex = viewModel.symbols.firstIndex(of: .moneySymbol) {
                let x = (moneyIndex + 1) % viewModel.symbols.count
                let y = (moneyIndex + 2) % viewModel.symbols.count
                finalReels = [moneyIndex, moneyIndex, moneyIndex, x, y, x, y, x, y]
            } else if force == "win_vertical", let moneyIndex = viewModel.symbols.firstIndex(of: .moneySymbol) {
                let x = (moneyIndex + 1) % viewModel.symbols.count
                let y = (moneyIndex + 2) % viewModel.symbols.count
                finalReels = [moneyIndex, x, y, moneyIndex, y, x, moneyIndex, x, y]
            } else if force == "win_diag_tlbr", let moneyIndex = viewModel.symbols.firstIndex(of: .moneySymbol) {
                let x = (moneyIndex + 1) % viewModel.symbols.count
                let y = (moneyIndex + 2) % viewModel.symbols.count
                finalReels = [moneyIndex, x, y, x, moneyIndex, x, y, x, moneyIndex]
            } else if force == "win_diag_trbl", let moneyIndex = viewModel.symbols.firstIndex(of: .moneySymbol) {
                let x = (moneyIndex + 1) % viewModel.symbols.count
                let y = (moneyIndex + 2) % viewModel.symbols.count
                finalReels = [x, y, moneyIndex, x, moneyIndex, x, moneyIndex, x, y]
            } else if force == "loss" {
                finalReels = [0, 1, 2, 1, 2, 0, 2, 0, 1]
            } else if force == "game_over" {
                finalReels = [0, 1, 2, 1, 2, 0, 2, 0, 1]
                isForcedGameOver = true
            }
        }
        #endif
        
        // If no forced result, generate random result
        if finalReels.isEmpty {
            let randomizer = ReelRandomizer()
            finalReels = randomizer.spin(symbols: viewModel.symbols)
        }
        
        // Stop reels column by column (left to right)
        let reelStops = [
            // First column (left)
            (0, 0.0),   // Top-left
            (3, 0.1),   // Middle-left
            (6, 0.2),   // Bottom-left
            // Second column (middle)
            (1, 0.5),   // Top-middle
            (4, 0.6),   // Center
            (7, 0.7),   // Bottom-middle
            // Third column (right)
            (2, 1.0),   // Top-right
            (5, 1.1),   // Middle-right
            (8, 1.2)    // Bottom-right
        ]
        
        for (reelIndex, delay) in reelStops {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.stoppedReels.insert(reelIndex)
                // Set the final symbol for this reel
                self.cyclingSymbols[reelIndex] = finalReels[reelIndex]
                
                // If this is the last reel to stop
                if reelIndex == 8 {
                    self.finishSpin(finalReels: finalReels, isForcedGameOver: isForcedGameOver)
                }
            }
        }
    }
    
    private func finishSpin(finalReels: [Int], isForcedGameOver: Bool) {
        // Set the final result in the view model
        viewModel.reels = finalReels
        
        // Stop cycling and show final result
        isCycling = false
        stoppedReels.removeAll()
        
        // Trigger the final animation
        withAnimation {
            self.animatingSymbol = true
        }
        
        // Check for wins
        let result = viewModel.checkWinning()
        if result.transferJackpot || result.payout > 0 {
            playSound(sound: "win", type: "mp3")
            haptics.notificationOccurred(.success)
        }

        if result.transferJackpot {
            alertTitle = "Jackpot!"
            alertMessage = "Congratulations! You won \(currency(result.awardedJackpot))!"
            showAlert = true
            flashingWinningIndexes = result.winningLineIndexes
            withAnimation(Animation.easeInOut(duration: 0.35).repeatForever(autoreverses: true)) {
                flashPhase.toggle()
            }
        } else if result.payout > 0 {
            alertTitle = "Congratulations!"
            alertMessage = "You won \(currency(result.awardedWin))!"
            showAlert = true
            flashingWinningIndexes = result.winningLineIndexes
            withAnimation(Animation.easeInOut(duration: 0.35).repeatForever(autoreverses: true)) {
                flashPhase.toggle()
            }
        }
        
        // Increment jackpot (skip if jackpot was just won)
        viewModel.incrementJackpotForSpin(skipIfJackpotWon: result.transferJackpot)
        
        // Check for game over
        if isForcedGameOver {
            viewModel.money = 0
        }
        
        // Check if player is out of money after this spin
        if viewModel.money <= 0 && !isGameOver {
            isGameOver = true
            showAlert = true
            alertTitle = "Game Over"
            alertMessage = "You are out of money!"
            playSound(sound: "game-over", type: "mp3")
        }
        
        // Re-enable spin button
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSpinDisabled = false
        }
    }
}


struct SlotMachineView_Previews: PreviewProvider {
    static var previews: some View {
        SlotMachineView()
    }
}
