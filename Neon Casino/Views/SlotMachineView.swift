//
//  SlotMachineView.swift
//  Neon Casino
//
//  Created by Kelvin Reid on 7/6/23.
//

import SwiftUI

struct SlotMachineView: View {
    // Symbols array
    let symbols: [SymbolImages] = [.barSymbol, .bellSymbol, .cherrySymbol, .cloverSymbol, .clubSymbol, .crownSymbol, .diamondSymbol, .fruitSymbol, .grapesSymbol, .heartSymbol, .horseshoeSymbol, .jewelSymbol, .lemonSymbol, .moneySymbol, .questionSymbol, .sevenSymbol, .spadeSymbol, .starSymbol, .strawberrySymbol, .watermelonSymbol, .winSymbol]
    
    let haptics = UINotificationFeedbackGenerator()
    
    // MARK: - Properties
    @State private var highScore = UserDefaults.standard.integer(forKey: "HighScore")
    @State private var jackpot = UserDefaults.standard.integer(forKey: "Jackpot")
    
    @State private var money = 100
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
        reels = reels.map({ _ in
            Int.random(in: 0...symbols.count - 1)
        })
        playSound(sound: "spin", type: "mp3")
        haptics.notificationOccurred(.success)
    }
    
    // Check if player won
    func checkWinning() {
        
        // MARK: - Test Winning
//        let winningCombination: [Int] = [0, 1, 2] // Modify this to include the jackpot symbol in the winning combination
        // Update the reels to force the winning combination
//        reels[winningCombination[0]] = symbols.firstIndex(of: .moneySymbol)!
//        reels[winningCombination[1]] = symbols.firstIndex(of: .moneySymbol)!
//        reels[winningCombination[2]] = symbols.firstIndex(of: .moneySymbol)!
        // MARK: - Test Winning
        
        // Define winning combinations and their respective payouts
        let winningCombinations: [[Int]] = [
            [0, 1, 2],  // Top row
            [3, 4, 5],  // Middle row
            [6, 7, 8],  // Bottom row
            [0, 4, 8],  // Diagonal from top-left to bottom-right
            [2, 4, 6]   // Diagonal from top-right to bottom-left
        ]
        
        let payouts: [SymbolImages: Int] = [
            .moneySymbol: 500,      // Payout for three "money" symbols
            .jewelSymbol: 400,     // Payout for three "jewel" symbols
            .crownSymbol: 300,   // Payout for three "crown" symbols
            .spadeSymbol: 200,   // Payout for three "spade" symbols
            // Add more symbols and corresponding payouts as needed
        ]
        
        var totalPayout = 0
        var transferJackpot = false

        // Check if any winning combination matches the current reel positions
        for combination in winningCombinations {
            let symbol = symbols[reels[combination[0]]]

            if reels[combination[0]] == reels[combination[1]] && reels[combination[1]] == reels[combination[2]] && symbol != .winSymbol {
                if let payout = payouts[symbol] {
                    totalPayout += payout
                    if symbol == .winSymbol {
                        transferJackpot = true
                    }
                }
            }
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

            // Player wins the jackpot
            if transferJackpot {
                money += jackpot
                jackpot = 0
                UserDefaults.standard.set(jackpot, forKey: "Jackpot")
                showAlert = true
                alertTitle = "Jackpot!"
                alertMessage = "Congratulations! You won $\(jackpot) dollars!"
                playSound(sound: "win", type: "mp3")
            }
        } else {
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
    
    // New Jackpot
    func updateJackpot(newJackpot: Int) {
        jackpot = newJackpot
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
    
    // MARK: - UI
    var body: some View {
        // Score fields
        VStack(alignment: .center, spacing: 10) {
            Text("JACKPOT")
                .modifier(JackpotLabelModifier())
            Text("$\(jackpot)")
                .modifier(ScoreNumberModifier())
            
            HStack {
                HStack {
                    Text("money".uppercased())
                        .modifier(ScoreLabelModifier())
                        .multilineTextAlignment(.trailing)
                    Text("$\(money)")
                        .modifier(ScoreNumberModifier())
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
                    
                    // 5. Increment Jackpot
                    updateJackpot(newJackpot: jackpot + 10)
                    
                    // 6. Game is Over
                    self.isGameOver()
                }) {
                    Image("spin-button-1")
                        .resizable()
                        .renderingMode(.original)
                        .modifier(SpinButtonModifier())
                }
                .frame(maxWidth: .infinity)

                Spacer()
            }
        }
        .frame(maxWidth: 100)
        
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
