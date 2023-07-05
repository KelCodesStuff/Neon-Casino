//
//  ContentView.swift
//  Slot Machine
//
//  Created by Kelvin Reid on 7/1/23.
//

import SwiftUI

struct ContentView: View {
    
    // Symbols array
    let symbols = ["bar", "bell", "cherry", "clover", "club", "crown", "diamond", "fruit", "grapes", "heart", "horseshoe", "jewel", "lemon", "money", "question", "seven", "spade", "star", "strawberry", "watermelon", "win"]
    let haptics = UINotificationFeedbackGenerator()
    
    // MARK: - Properties
    @State private var highScore = UserDefaults.standard.integer(forKey: "HighScore")
    @State private var jackpot = UserDefaults.standard.integer(forKey: "Jackpot")
    @State private var credits = 1000
    @State private var betAmount = 5
    @State private var reels = [0, 1, 2, 3, 4, 5, 6, 7, 8]

    @State private var activeBet5 = true
    @State private var activeBet10 = false
    @State private var activeBet25 = false
    @State private var activeBet50 = false
    
    @State private var showInfoView = false
    @State private var showGameOverModal = false
    
    @State private var animatingSymbol = false
    @State private var animatingModal = false
    @State private var animatingIcon = false
    
    // MARK: - FUNCTIONS (GAME LOGIC)
    
    // Function to spin the reels
    func spinReels() {
//          reels[0] = Int.random(in: 0...symbols.count - 1)
        reels = reels.map({ _ in
            Int.random(in: 0...symbols.count - 1)
        })
        playSound(sound: "spin", type: "mp3")
        haptics.notificationOccurred(.success)
    }
    
    // MARK: - Check if player won
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
    
    // MARK: - Player Won
    func playerWins() {
        credits += betAmount * 100
    }
    
    // MARK: - New Jackpot
    func updateJackpot(newJackpot: Int) {
        jackpot = newJackpot
        UserDefaults.standard.set(jackpot, forKey: "Jackpot")
    }
    
    // MARK: - New High Score
    func newHighScore() {
        highScore = credits
        // Saves data locally
        UserDefaults.standard.set(highScore, forKey: "HighScore")
        playSound(sound: "high-score", type: "mp3")
    }
    
    // MARK: - Player Loses
    func playerLoses() {
        credits -= betAmount
    }
    
    // MARK: - Set Bet to 5
    func activateBet5() {
        betAmount = 5
        activeBet5 = true
        activeBet10 = false
        activeBet25 = false
        activeBet50 = false
        playSound(sound: "bet-chip", type: "mp3")
        haptics.notificationOccurred(.success)
    }
    
    // MARK: - Set Bet to 10
    func activateBet10() {
        betAmount = 10
        activeBet5 = false
        activeBet10 = true
        activeBet25 = false
        activeBet50 = false
        playSound(sound: "bet-chip", type: "mp3")
        haptics.notificationOccurred(.success)
    }
    
    // MARK: - Set Bet to 25
    func activateBet25() {
        betAmount = 25
        activeBet5 = false
        activeBet10 = false
        activeBet25 = true
        activeBet50 = false
        playSound(sound: "bet-chip", type: "mp3")
        haptics.notificationOccurred(.success)
    }
    
    // MARK: - Set Bet to 50
    func activateBet50() {
        betAmount = 50
        activeBet5 = false
        activeBet10 = false
        activeBet25 = false
        activeBet50 = true
        playSound(sound: "bet-chip", type: "mp3")
        haptics.notificationOccurred(.success)
    }
    
    // MARK: - Game Over
    func isGameOver() {
        if credits <= 0 {
            // Show game over modal
            showGameOverModal = true
            playSound(sound: "game-over", type: "mp3")
        }
    }
    
    // MARK: - Reset Game
    func resetGame() {
        UserDefaults.standard.set(0, forKey: "HighScore")
        highScore = 0
        credits = 1000
        activateBet10()
        playSound(sound: "chime-up", type: "mp3")
    }
        
    // MARK: BODY
    var body: some View {
        ZStack {
            // MARK: - Background
            Image("slots-background")
                .resizable()
                .scaledToFill()
                .clipped()
            
            // MARK: - GAME UI
            VStack(alignment: .center, spacing: 5) {
                // MARK: Logo Header
                LogoView(logoFileName: "slots-logo")
                
                // MARK: - Score
                VStack(alignment: .center, spacing: 10) {
                    Text("JACKPOT")
                        .modifier(JackpotLabelModifier())
                    Text("\(jackpot)")
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

                // MARK: - Slot Machine
                VStack(alignment: .center, spacing: 0) {
                    HStack {
                        // MARK: - Reel #1 (Row 1)
                        ZStack {
                            ReelView()
                            Image(symbols[reels[0]])
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
                        
                        // MARK: - Reel #2 (Row 1)
                        ZStack {
                            ReelView()
                            Image(symbols[reels[1]])
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
                        
                        // MARK: - Reel #3 (Row 1)
                        ZStack {
                            ReelView()
                            Image(symbols[reels[2]])
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
                        // MARK: - REEL #1 (Row 2)
                        ZStack {
                            ReelView()
                            Image(symbols[reels[3]])
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
                        
                        // MARK: - Reel #2 (Row 2)
                        ZStack {
                            ReelView()
                            Image(symbols[reels[4]])
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
                        
                        // MARK: - Reel #3 (Row 2)
                        ZStack {
                            ReelView()
                            Image(symbols[reels[5]])
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
                        // MARK: - REEL #1 (Row 3)
                        ZStack {
                            ReelView()
                            Image(symbols[reels[6]])
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
                        
                        // MARK: - Reel #2 (Row 3)
                        ZStack {
                            ReelView()
                            Image(symbols[reels[7]])
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
                        
                        // MARK: - Reel #3 (Row 3)
                        ZStack {
                            ReelView()
                            Image(symbols[reels[8]])
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
                }
                .frame(maxWidth: 100)

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

                // Spin buttons
                HStack {
                    Spacer()
                    
                    // MARK: - Bet 5 button
                    HStack(alignment: .center, spacing: 10) {
                        Button(action: {
                            self.activateBet5()
                        }) {
                            Image("5-chip")
                                .resizable()
                                .renderingMode(.original)
                                .modifier(BetButtonModifier())
                        }
                    }
                    Spacer()
                    
                    // MARK: - Bet 10 button
                    HStack(alignment: .center, spacing: 10) {
                        Button(action: {
                            self.activateBet10()
                        }) {
                            Image("10-chip")
                                .resizable()
                                .renderingMode(.original)
                                .modifier(BetButtonModifier())
                        }
                    }
                    Spacer()
                    
                    // MARK: - Bet 25 button
                    HStack(alignment: .center, spacing: 10) {
                        Button(action: {
                            self.activateBet25()
                        }) {
                            Image("25-chip")
                                .resizable()
                                .renderingMode(.original)
                                .modifier(BetButtonModifier())
                        }
                    }
                    Spacer()
                    
                    // MARK: - Bet 50 button
                    HStack(alignment: .center, spacing: 10) {
                        Button(action: {
                            self.activateBet50()
                        }) {
                            Image("50-chip")
                                .resizable()
                                .renderingMode(.original)
                                .modifier(BetButtonModifier())
                        }
                    }
                    Spacer()
                }

            }
                // MARK: - Nav bar buttons
                .overlay(
                    // Reset game button
                    Button(action: {
                        self.resetGame()
                    }) {
                        Image(systemName: "arrow.2.circlepath.circle")
                    }
                    .modifier(ButtonModifier()), alignment: .topLeading
                )
                .overlay(
                    // Info button
                    Button(action: {
                        self.showInfoView = true
                    }) {
                        Image(systemName: "info.circle")
                    }
                    .modifier(ButtonModifier()), alignment: .topTrailing
                )
                .padding()
                .frame(maxWidth: 720)
                .blur(radius:  showGameOverModal ? 5 : 0 , opaque: false)

            // MARK: - GAMEOVER MODAL
            if showGameOverModal {
                ZStack {
                    Color("ColorBlackTransparent")
                        .edgesIgnoringSafeArea(.all)
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
        }
        .sheet(isPresented: $showInfoView) {
            InfoView()
        }
    }
}

// MARK: - PREVIEW
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
