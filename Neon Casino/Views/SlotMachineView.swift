//
//  SlotMachineView.swift
//  Neon Casino
//
//  Created by Kelvin Reid on 7/6/23.
//

import SwiftUI
import UIKit

struct SlotMachineView: View {
    // Symbols array
    let symbols: [SymbolImages] = [.barSymbol, .bellSymbol, .cherrySymbol, .cloverSymbol, .clubSymbol, .crownSymbol, .diamondSymbol, .fruitSymbol, .grapesSymbol, .heartSymbol, .horseshoeSymbol, .jewelSymbol, .lemonSymbol, .moneySymbol, .questionSymbol, .sevenSymbol, .spadeSymbol, .starSymbol, .strawberrySymbol, .watermelonSymbol, .winSymbol]
    
    let haptics = UINotificationFeedbackGenerator()
    private let defaultJackpot = 100_000
    
    // MARK: - Properties
    @State private var highScore = UserDefaults.standard.integer(forKey: "HighScore")
    @State private var jackpot = (UserDefaults.standard.object(forKey: "Jackpot") as? Int) ?? 100_000
    
    @State private var money = 1000
    @State private var moneyWon = 0
    @State private var betAmount = 5
    @State private var reels = [0, 1, 2, 3, 4, 5, 6, 7, 8]
    
    @State private var activeBet5 = true
    @State private var activeBet10 = false
    @State private var activeBet25 = false
    @State private var activeBet50 = false
    
    @State private var animatingSymbol = false
    @State private var showInfoView = false
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // MARK: - Functions
    func setBetAmount(_ amount: Int) {
        betAmount = amount
        activeBet5 = (amount == 5)
        activeBet10 = (amount == 10)
        activeBet25 = (amount == 25)
        activeBet50 = (amount == 50)
        playSound(sound: "bet-chip", type: "mp3")
        haptics.notificationOccurred(.success)
    }
    
    // Function to spin the reels
    func spinReels() {
        // Deterministic behavior for UI tests via launch environment
        let env = ProcessInfo.processInfo.environment
        if let force = env["UITEST_FORCE"] {
            if force == "win_money", let moneyIndex = symbols.firstIndex(of: .moneySymbol) {
                // Force ONLY the top row to be a win; ensure no other winning lines
                let x = (moneyIndex + 1) % symbols.count
                let y = (moneyIndex + 2) % symbols.count
                reels = [
                    moneyIndex, moneyIndex, moneyIndex, // top row win
                    x, y, x,                             // middle row non-win
                    y, x, y                              // bottom row non-win; diagonals broken
                ]
            } else if force == "jackpot", let winIndex = symbols.firstIndex(of: .winSymbol) {
                // Force jackpot on top row; others non-winning
                let x = (winIndex + 1) % symbols.count
                let y = (winIndex + 2) % symbols.count
                reels = [
                    winIndex, winIndex, winIndex,
                    x, y, x,
                    y, x, y
                ]
            } else if force == "loss" {
                // Ensure there are no three-of-a-kind on any winning line
                let a = 0
                let b = min(1, symbols.count - 1)
                let c = min(2, symbols.count - 1)
                reels = [
                    a, b, c,
                    b, c, a,
                    c, a, b
                ]
            } else {
                reels = reels.map({ _ in Int.random(in: 0...symbols.count - 1) })
            }
        } else {
            reels = reels.map({ _ in Int.random(in: 0...symbols.count - 1) })
        }
        playSound(sound: "spin", type: "mp3")
        haptics.notificationOccurred(.success)
    }
    
    // Check if player won
    func checkWinning() {
        // Evaluate using the rules engine
        let evaluation = GameRules.evaluate(reels: reels, symbols: symbols)
        var totalPayout = evaluation.totalPayout
        let transferJackpot = evaluation.transferJackpot

        // Handle jackpot first (jackpot symbol has no separate symbol payout)
        if transferJackpot {
            let awarded = jackpot
            money += awarded
            jackpot = defaultJackpot
            UserDefaults.standard.set(jackpot, forKey: "Jackpot")
            showAlert = true
            alertTitle = "Jackpot!"
            alertMessage = "Congratulations! You won $\(awarded) dollars!"
            playSound(sound: "win", type: "mp3")
        }

        if totalPayout > 0 {
            // Player Wins
            playerWins(totalPayout: totalPayout)
            
            // New HighScore
            if money > highScore {
                newHighScore()
            } else {
                playSound(sound: "win", type: "mp3")
            }
        } else if !transferJackpot {
            // Player loses
            playerLoses()
        }
    }
    
    // Player Wins
    func playerWins(totalPayout: Int) {
        moneyWon = totalPayout * betAmount
        money += moneyWon
        showAlert = true
        alertTitle = "Congratulations!"
        alertMessage = "You won $\(moneyWon) dollars!"
        playSound(sound: "win", type: "mp3")
    }
    
    // Player Loses
    func playerLoses() {
        money -= betAmount
        if money < 0 {
            money = 0
        }
    }
    
    // Game Over
    func isGameOver() {
        if money <= 0 {
            showAlert = true
            alertTitle = "Game Over"
            alertMessage = "You are out of money."
            money = 100
            setBetAmount(5)
            playSound(sound: "game-over", type: "mp3")
        }
    }
    
    // Progressive Jackpot increment: +10% of bet each spin
    func incrementJackpotForSpin() {
        let increment = Int(round(Double(betAmount) * 0.10))
        let newValue = jackpot + increment
        jackpot = max(newValue, defaultJackpot)
        UserDefaults.standard.set(jackpot, forKey: "Jackpot")
    }
    
    // New High Score
    func newHighScore() {
        highScore = money
        // Saves data locally
        UserDefaults.standard.set(highScore, forKey: "HighScore")
        playSound(sound: "high-score", type: "mp3")
    }
    
    // Reset Game
    func resetGame() {
        money = 100
        setBetAmount(5)
    }
    
    #if DEBUG
    // Test-only helper to force reels to specific values
    func forceReelsForTesting(_ newReels: [Int]) {
        guard newReels.count == 9 else { return }
        reels = newReels
    }
    #endif
    
    // MARK: - UI
    var body: some View {
        // Score fields
        VStack(alignment: .center, spacing: 10) {
            Text("JACKPOT")
                .modifier(JackpotLabelModifier())
            Text("$\(jackpot)")
                .modifier(ScoreNumberModifier())
                .accessibilityIdentifier("jackpotValueLabel")
            
            HStack {
                HStack {
                    Text("money".uppercased())
                        .modifier(ScoreLabelModifier())
                        .multilineTextAlignment(.trailing)
                    Text("$\(money)")
                        .modifier(ScoreNumberModifier())
                        .accessibilityIdentifier("moneyValueLabel")
                }
                .modifier(ScoreCapsuleModifier())
                Spacer()
                HStack {
                    Text("\(highScore)")
                        .modifier(ScoreNumberModifier())
                        .multilineTextAlignment(.leading)
                    Text("High\nScore".uppercased())
                        .modifier(ScoreLabelModifier())
                }
                .modifier(ScoreCapsuleModifier())
            }
        }
        Spacer()
        
        VStack(alignment: .center, spacing: 0) {
            HStack {
                // Reel 1 (Row 1)
                ZStack {
                    ReelView()
                    Image(symbols[reels[0]].rawValue)
                        .resizable()
                        .modifier(SymbolImageModifier())
                        .opacity(animatingSymbol ? 1 : 0)
                        .offset(y: animatingSymbol ? 0 : 50)
                        .animation(.easeOut(duration: Double.random(in: 0.5...0.7)), value: animatingSymbol)
                        .onAppear(perform: {
                            self.animatingSymbol.toggle()
                            playSound(sound: "rise-up", type: "mp3")
                        })
                }
                
                // Reel 2 (Row 1)
                ZStack {
                    ReelView()
                    Image(symbols[reels[1]].rawValue)
                        .resizable()
                        .modifier(SymbolImageModifier())
                        .opacity(animatingSymbol ? 1 : 0)
                        .offset(y: animatingSymbol ? 0 : 50)
                        .animation(.easeOut(duration: Double.random(in: 0.5...0.7)), value: animatingSymbol)
                        .onAppear(perform: {
                            self.animatingSymbol.toggle()
                            playSound(sound: "rise-up", type: "mp3")
                        })
                }
                
                // Reel 3 (Row 1)
                ZStack {
                    ReelView()
                    Image(symbols[reels[2]].rawValue)
                        .resizable()
                        .modifier(SymbolImageModifier())
                        .opacity(animatingSymbol ? 1 : 0)
                        .offset(y: animatingSymbol ? 0 : 50)
                        .animation(.easeOut(duration: Double.random(in: 0.5...0.7)), value: animatingSymbol)
                        .onAppear(perform: {
                            self.animatingSymbol.toggle()
                            playSound(sound: "rise-up", type: "mp3")
                        })
                }
            }
            
            HStack {
                // Reel 1 (Row 2)
                ZStack {
                    ReelView()
                    Image(symbols[reels[3]].rawValue)
                        .resizable()
                        .modifier(SymbolImageModifier())
                        .opacity(animatingSymbol ? 1 : 0)
                        .offset(y: animatingSymbol ? 0 : 50)
                        .animation(.easeOut(duration: Double.random(in: 0.5...0.7)), value: animatingSymbol)
                        .onAppear(perform: {
                            self.animatingSymbol.toggle()
                            playSound(sound: "rise-up", type: "mp3")
                        })
                }
                
                // Reel 2 (Row 2)
                ZStack {
                    ReelView()
                    Image(symbols[reels[4]].rawValue)
                        .resizable()
                        .modifier(SymbolImageModifier())
                        .opacity(animatingSymbol ? 1 : 0)
                        .offset(y: animatingSymbol ? 0 : 50)
                        .animation(.easeOut(duration: Double.random(in: 0.5...0.7)), value: animatingSymbol)
                        .onAppear(perform: {
                            self.animatingSymbol.toggle()
                            playSound(sound: "rise-up", type: "mp3")
                        })
                }
                
                // Reel 3 (Row 2)
                ZStack {
                    ReelView()
                    Image(symbols[reels[5]].rawValue)
                        .resizable()
                        .modifier(SymbolImageModifier())
                        .opacity(animatingSymbol ? 1 : 0)
                        .offset(y: animatingSymbol ? 0 : 50)
                        .animation(.easeOut(duration: Double.random(in: 0.5...0.7)), value: animatingSymbol)
                        .onAppear(perform: {
                            self.animatingSymbol.toggle()
                            playSound(sound: "rise-up", type: "mp3")
                        })
                }
            }
            
            HStack {
                // Reel 1 (Row 3)
                ZStack {
                    ReelView()
                    Image(symbols[reels[6]].rawValue)
                        .resizable()
                        .modifier(SymbolImageModifier())
                        .opacity(animatingSymbol ? 1 : 0)
                        .offset(y: animatingSymbol ? 0 : 50)
                        .animation(.easeOut(duration: Double.random(in: 0.5...0.7)), value: animatingSymbol)
                        .onAppear(perform: {
                            self.animatingSymbol.toggle()
                            playSound(sound: "rise-up", type: "mp3")
                        })
                }
                
                // Reel 2 (Row 3)
                ZStack {
                    ReelView()
                    Image(symbols[reels[7]].rawValue)
                        .resizable()
                        .modifier(SymbolImageModifier())
                        .opacity(animatingSymbol ? 1 : 0)
                        .offset(y: animatingSymbol ? 0 : 50)
                        .animation(.easeOut(duration: Double.random(in: 0.5...0.7)), value: animatingSymbol)
                        .onAppear(perform: {
                            self.animatingSymbol.toggle()
                            playSound(sound: "rise-up", type: "mp3")
                        })
                }
                
                // Reel 3 (Row 3)
                ZStack {
                    ReelView()
                    Image(symbols[reels[8]].rawValue)
                        .resizable()
                        .modifier(SymbolImageModifier())
                        .opacity(animatingSymbol ? 1 : 0)
                        .offset(y: animatingSymbol ? 0 : 50)
                        .animation(.easeOut(duration: Double.random(in: 0.5...0.7)), value: animatingSymbol)
                        .onAppear(perform: {
                            self.animatingSymbol.toggle()
                            playSound(sound: "rise-up", type: "mp3")
                        })
                }
            }
            Spacer()
            
            // MARK: - Wager Buttons
            HStack {
                Spacer()
                
                // 5 button
                HStack(alignment: .center, spacing: 10) {
                    Button(action: {
                        self.setBetAmount(5)
                    }) {
                        Image("5-chip")
                            .resizable()
                            .renderingMode(.original)
                            .modifier(BetButtonModifier())
                    }
                }
                Spacer()
                
                // 10 button
                HStack(alignment: .center, spacing: 10) {
                    Button(action: {
                        self.setBetAmount(10)
                    }) {
                        Image("10-chip")
                            .resizable()
                            .renderingMode(.original)
                            .modifier(BetButtonModifier())
                    }
                }
                Spacer()
                
                // 25 button
                HStack(alignment: .center, spacing: 10) {
                    Button(action: {
                        self.setBetAmount(25)
                    }) {
                        Image("25-chip")
                            .resizable()
                            .renderingMode(.original)
                            .modifier(BetButtonModifier())
                    }
                }
                Spacer()
                
                // 50 button
                HStack(alignment: .center, spacing: 10) {
                    Button(action: {
                        self.setBetAmount(50)
                    }) {
                        Image("50-chip")
                            .resizable()
                            .renderingMode(.original)
                            .modifier(BetButtonModifier())
                    }
                }
                Spacer()
            }
            
            HStack {
                Spacer()
                // MARK: - Spin Button
                Button(action: {
                    // 1. Set the default State: No animation
                    withAnimation {
                        self.animatingSymbol = false
                    }
                    
                    // 2. Spin the reels with changing the symbols
                    self.spinReels()
                    
                    // 3. Trigger the animation after changing the symbols
                    withAnimation {
                        self.animatingSymbol = true
                    }
                    
                    // 4. Check Winning
                    self.checkWinning()
                    
                    // 5. Increment Jackpot by 10% of bet
                    incrementJackpotForSpin()
                    
                    // 6. Game is Over
                    self.isGameOver()
                }) {
                    Image("spin-button-1")
                        .resizable()
                        .renderingMode(.original)
                        .modifier(SpinButtonModifier())
                }
                .accessibilityIdentifier("spinButton")
                .frame(maxWidth: .infinity)

                Spacer()
            }
        }
        // Allow natural sizing; parent view may constrain
        
        // Combined Alert
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}


struct SlotMachineView_Previews: PreviewProvider {
    static var previews: some View {
        SlotMachineView()
    }
}
