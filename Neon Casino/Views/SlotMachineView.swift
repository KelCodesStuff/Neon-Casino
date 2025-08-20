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
                            Image(viewModel.symbols[viewModel.reels[index]].rawValue)
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
                    // 1. Set the default State: No animation and duration
                    currentSpinDuration = 0.7
                    withAnimation {
                        self.animatingSymbol = false
                    }
                    
                    // 2. Spin the reels with changing the symbols
                    var isForcedGameOver = false
                    #if DEBUG
                    let force = ProcessInfo.processInfo.environment["UITEST_FORCE"]
                    viewModel.spinReels(forceMode: force)
                    if force == "game_over" { isForcedGameOver = true }
                    #else
                    viewModel.spinReels()
                    #endif
                    playSound(sound: "spin", type: "mp3")
                    haptics.notificationOccurred(.success)
                    
                    // 3. Trigger the animation after changing the symbols
                    withAnimation {
                        self.animatingSymbol = true
                    }
                    
                    // 4. Check Winning
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
                        // Start flashing
                        withAnimation(Animation.easeInOut(duration: 0.35).repeatForever(autoreverses: true)) {
                            flashPhase.toggle()
                        }
                    } else if result.payout > 0 {
                        // Show standard win alert for non-jackpot wins
                        alertTitle = "Congratulations!"
                        alertMessage = "You won \(currency(result.awardedWin))!"
                        showAlert = true
                        flashingWinningIndexes = result.winningLineIndexes
                        withAnimation(Animation.easeInOut(duration: 0.35).repeatForever(autoreverses: true)) {
                            flashPhase.toggle()
                        }
                    } else if false { // placeholder for bonus UI if needed
                        // In future, show bonus game activation
                    }
                    
                    // 5. Increment Jackpot by 10% of bet
                    viewModel.incrementJackpotForSpin(skipIfJackpotWon: result.transferJackpot)
                    
                    // 6. Game is Over
                    if isForcedGameOver {
                        viewModel.money = 0
                    }
                    if viewModel.money <= 0 && !isGameOver {
                        isGameOver = true
                        showAlert = true
                        alertTitle = "Game Over"
                        alertMessage = "You are out of money!"
                        playSound(sound: "game-over", type: "mp3")
                    }

                    // Re-enable spin after the animation completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + currentSpinDuration + 0.05) {
                        isSpinDisabled = false
                    }
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
}


struct SlotMachineView_Previews: PreviewProvider {
    static var previews: some View {
        SlotMachineView()
    }
}
