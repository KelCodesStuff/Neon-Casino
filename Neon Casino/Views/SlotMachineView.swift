//
//  SlotMachineView.swift
//  Neon Casino
//
//  Created by Kelvin Reid on 7/6/23.
//

import SwiftUI

struct SlotMachineView: View {
    // Symbols array
    let symbols: [SymbolImages] = [.bar, .bell, .cherry, .clover, .club, .crown, .diamond, .fruit, .grapes, .heart, .horseshoe, .jewel, .lemon, .money, .question, .seven, .spade, .star, .strawberry, .watermelon, .win]
    
    let haptics = UINotificationFeedbackGenerator()
    
    // MARK: - Properties
    @State private var highScore = UserDefaults.standard.integer(forKey: "HighScore")
    @State private var jackpot = UserDefaults.standard.integer(forKey: "Jackpot")
    @State private var credits = 100
    @State private var betAmount = 5
    @State private var reels = [0, 1, 2, 3, 4, 5, 6, 7, 8]
    
    @State private var activeBet5 = true
    @State private var activeBet10 = false
    @State private var activeBet25 = false
    @State private var activeBet50 = false
    
    @State private var animatingSymbol = false
    @State private var showInfoView = false
    @State private var showGameOverAlert = false
    @State private var showGameOverModal = false
    
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
        let firstSymbol = reels[0]
        var allEqual = true
        
        for symbol in reels {
            if symbol != firstSymbol {
                allEqual = false
                break
            }
        }
        
        if allEqual {
            // Player Wins
            playerWins()
            
            // New HighScore
            if credits > highScore {
                newHighScore()
            } else {
                playSound(sound: "win", type: "mp3")
            }
        } else {
            // Player loses
            playerLoses()
        }
    }
    
    // Player Won
    func playerWins() {
        credits += betAmount * 100
    }
    
    // New Jackpot
    func updateJackpot(newJackpot: Int) {
        jackpot = newJackpot
        UserDefaults.standard.set(jackpot, forKey: "Jackpot")
    }
    
    // New High Score
    func newHighScore() {
        highScore = credits
        // Saves data locally
        UserDefaults.standard.set(highScore, forKey: "HighScore")
        playSound(sound: "high-score", type: "mp3")
    }
    
    // Player Loses
    func playerLoses() {
        credits -= betAmount
        if credits < 0 {
            credits = 0
        }
    }
    
    // Game Over
    func isGameOver() {
        if credits <= 0 {
            showGameOverAlert = true
            showGameOverModal = true
            playSound(sound: "game-over", type: "mp3")
        }
    }
    
    // Reset Game
    func resetGame() {
        credits = 100
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
                    Text("Your\nCredits".uppercased())
                        .modifier(ScoreLabelModifier())
                        .multilineTextAlignment(.trailing)
                    Text("\(credits)")
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
        
        // Game Over Alert
        .alert(isPresented: $showGameOverAlert) {
            Alert(
                title: Text("Game Over"),
                message: Text("You are out of credits!"),
                dismissButton: .default(
                    Text("OK"),
                    action: {
                        resetGame()
                    }
                )
            )
        }
    }
}


/*
        // MARK: - Game over modal
        if showGameOverModal {
            ZStack {
                Color(.black)
                    .ignoresSafeArea(.all)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                VStack {
                    Text("GAME OVER")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.heavy)
                        .foregroundColor(Color.white)
                        .padding()
                        .frame(minWidth: 280, idealWidth: 280, maxWidth: 320)
                        .background(Color("ColorGreen"))
                    
                    Spacer()
                    VStack {
                        Image("main-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 150)
                        Text("No more credits!\n Play again!")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(Color.white)
                            .multilineTextAlignment(.center)
                        Button {
                            self.showGameOverModal = false
                            self.credits = 100
                        } label: {
                            Text("New Game".uppercased())
                                .foregroundColor(Color.white)
                        }
                        .padding(.vertical,10)
                        .padding(.horizontal, 20)
                        .background(
                            Capsule()
                                .strokeBorder(lineWidth: 2)
                                .foregroundColor(Color("ColorWhite"))
                        )
                    }
                    Spacer()
                }
                .frame(minWidth: 280, idealWidth: 280, maxWidth: 320, minHeight: 280, idealHeight: 300, maxHeight: 350, alignment: .center)
                .background(Color("ColorGold"))
                .cornerRadius(20)
            }.onAppear(perform: {
                playSound(sound: "drum-music", type: "mp3")
              })
        }
*/

struct SlotMachineView_Previews: PreviewProvider {
    static var previews: some View {
        SlotMachineView()
    }
}
