//
//  InfoView.swift
//  Slot Machine
//
//  Created by Kelvin Reid on 7/1/23.
//

import SwiftUI

struct InfoView: View {
    // Presents static app information and a dynamic pay table derived from
    // the (GameRules). This ensures the UI stays in sync with
    // the actual payout logic without manual edits.
    
    // MARK: - Principal Properties
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            LogoView()
            Spacer()
            Form {
                // Pay table
                Section(header: Text("Payouts (bet x multiplier)")) {
                    ForEach(payRows) { row in
                        if row.isCategoryHeader {
                            // Category header styling
                            HStack {
                                Text(row.title)
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .padding(.top, 8)
                                    .padding(.bottom, 4)
                                Spacer()
                            }
                        } else {
                            // Regular symbol row
                            HStack {
                                // Show three of the symbol to indicate "3 in a row" condition
                                if let sym = row.symbol {
                                    ForEach(0..<3, id: \.self) { _ in
                                        Image(sym.rawValue)
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                    }
                                } else {
                                    // Keep spacing consistent when no symbol is present
                                    Spacer().frame(width: 96)
                                }
                                Text(row.title)
                                Spacer()
                                if let amt = row.amount {
                                    Text("×\(amt)")
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                }
                Section(header: Text("Jackpot")) {
                    HStack {
                        // Show nine win symbols in 3x3 grid to indicate jackpot condition
                        VStack(spacing: 2) {
                            HStack(spacing: 2) {
                                ForEach(0..<3, id: \.self) { _ in
                                    Image(SymbolImages.winSymbol.rawValue)
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                }
                            }
                            HStack(spacing: 2) {
                                ForEach(0..<3, id: \.self) { _ in
                                    Image(SymbolImages.winSymbol.rawValue)
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                }
                            }
                            HStack(spacing: 2) {
                                ForEach(0..<3, id: \.self) { _ in
                                    Image(SymbolImages.winSymbol.rawValue)
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                }
                            }
                        }
                        Text("Jackpot awarded")
                    }
                }
                Section(header: Text("Bonus")) {
                    HStack {
                        // Visual cue that three question symbols (in a line) start the bonus
                        ForEach(0..<3, id: \.self) { _ in
                            Image(SymbolImages.questionSymbol.rawValue)
                                .resizable().frame(width: 30, height: 30)
                        }
                        Text("Three Question symbols activates bonus round")
                    }
                }
                // About
                Section(header: Text("Information"), footer: Text("")) {
                    KeyValueRow("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                    Link(destination: URL(string: "https://sites.google.com/view/onevrtech/privacy-policy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                            .foregroundColor(Color.green)
                    }
                    Link(destination: URL(string: "https://sites.google.com/view/onevrtech/terms-of-service")!) {
                        Label("Terms of Service", systemImage: "note.text")
                            .foregroundColor(Color.green)
                    }
                    Link(destination: URL(string: "https://sites.google.com/view/onevrtech/end-user-license-agreement")!) {
                        Label("EULA", systemImage: "hand.thumbsup")
                            .foregroundColor(Color.green)
                    }
                }
            }
            .font(.system(.body, design: .rounded))
        }
        .padding(.top, 40)
        .overlay(
            Button(action: {
                audioPlayer?.stop()
                // Closing view
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle")
                    .font(.title)
            }
            .padding(.top, 30)
            .padding(.trailing, 20)
            .accentColor(Color.secondary), alignment: .topTrailing
        )
        .onAppear(perform: {
            playSound(sound: "background-music", type: "mp3")
        })
    }
    
    // MARK: - Pay rows
    struct PayRow: Identifiable {
        let id = UUID()
        let symbol: SymbolImages?   // nil for category headers
        let title: String           // Localized display title
        let amount: Int?            // Base payout (before bet multiplier), nil for category headers
        let isCategoryHeader: Bool  // true for category labels like "High-Value Symbols:"
    }

    private var payRows: [PayRow] {
        var rows: [PayRow] = []
        
        // High-Value Symbols (200-120x)
        rows.append(PayRow(symbol: nil, title: "High-Value Symbols:", amount: nil, isCategoryHeader: true))
        rows.append(PayRow(symbol: .moneySymbol, title: displayName(.moneySymbol), amount: GameRules.payouts[.moneySymbol], isCategoryHeader: false))
        rows.append(PayRow(symbol: .sevenSymbol, title: displayName(.sevenSymbol), amount: GameRules.payouts[.sevenSymbol], isCategoryHeader: false))
        rows.append(PayRow(symbol: .barSymbol, title: displayName(.barSymbol), amount: GameRules.payouts[.barSymbol], isCategoryHeader: false))
        
        // Medium-Value Symbols (40x)
        rows.append(PayRow(symbol: nil, title: "Medium-Value Symbols:", amount: nil, isCategoryHeader: true))
        rows.append(PayRow(symbol: .winSymbol, title: displayName(.winSymbol), amount: GameRules.payouts[.winSymbol], isCategoryHeader: false))
        rows.append(PayRow(symbol: .jewelSymbol, title: displayName(.jewelSymbol), amount: GameRules.payouts[.jewelSymbol], isCategoryHeader: false))
        rows.append(PayRow(symbol: .crownSymbol, title: displayName(.crownSymbol), amount: GameRules.payouts[.crownSymbol], isCategoryHeader: false))
        
        // Card Symbols (20x)
        rows.append(PayRow(symbol: nil, title: "Card Symbols:", amount: nil, isCategoryHeader: true))
        rows.append(PayRow(symbol: .spadeSymbol, title: displayName(.spadeSymbol), amount: GameRules.payouts[.spadeSymbol], isCategoryHeader: false))
        rows.append(PayRow(symbol: .clubSymbol, title: displayName(.clubSymbol), amount: GameRules.payouts[.clubSymbol], isCategoryHeader: false))
        rows.append(PayRow(symbol: .diamondSymbol, title: displayName(.diamondSymbol), amount: GameRules.payouts[.diamondSymbol], isCategoryHeader: false))
        rows.append(PayRow(symbol: .heartSymbol, title: displayName(.heartSymbol), amount: GameRules.payouts[.heartSymbol], isCategoryHeader: false))
        
        // Lucky Symbols (4x)
        rows.append(PayRow(symbol: nil, title: "Lucky Symbols:", amount: nil, isCategoryHeader: true))
        rows.append(PayRow(symbol: .starSymbol, title: displayName(.starSymbol), amount: GameRules.payouts[.starSymbol], isCategoryHeader: false))
        rows.append(PayRow(symbol: .cloverSymbol, title: displayName(.cloverSymbol), amount: GameRules.payouts[.cloverSymbol], isCategoryHeader: false))
        rows.append(PayRow(symbol: .horseshoeSymbol, title: displayName(.horseshoeSymbol), amount: GameRules.payouts[.horseshoeSymbol], isCategoryHeader: false))
        rows.append(PayRow(symbol: .bellSymbol, title: displayName(.bellSymbol), amount: GameRules.payouts[.bellSymbol], isCategoryHeader: false))
        
        // Fruit Symbols (2x)
        rows.append(PayRow(symbol: nil, title: "Fruit Symbols:", amount: nil, isCategoryHeader: true))
        rows.append(PayRow(symbol: .cherrySymbol, title: displayName(.cherrySymbol), amount: GameRules.payouts[.cherrySymbol], isCategoryHeader: false))
        rows.append(PayRow(symbol: .fruitSymbol, title: displayName(.fruitSymbol), amount: GameRules.payouts[.fruitSymbol], isCategoryHeader: false))
        rows.append(PayRow(symbol: .grapesSymbol, title: displayName(.grapesSymbol), amount: GameRules.payouts[.grapesSymbol], isCategoryHeader: false))
        rows.append(PayRow(symbol: .lemonSymbol, title: displayName(.lemonSymbol), amount: GameRules.payouts[.lemonSymbol], isCategoryHeader: false))
        rows.append(PayRow(symbol: .strawberrySymbol, title: displayName(.strawberrySymbol), amount: GameRules.payouts[.strawberrySymbol], isCategoryHeader: false))
        rows.append(PayRow(symbol: .watermelonSymbol, title: displayName(.watermelonSymbol), amount: GameRules.payouts[.watermelonSymbol], isCategoryHeader: false))
        
        return rows
    }

    private func displayName(_ s: SymbolImages) -> String {
        // Human-friendly names for all symbols
        switch s {
        case .moneySymbol: return "Money"
        case .sevenSymbol: return "Seven"
        case .barSymbol: return "Bar"
        case .winSymbol: return "Win"
        case .jewelSymbol: return "Jewel"
        case .crownSymbol: return "Crown"
        case .spadeSymbol: return "Spade"
        case .clubSymbol: return "Club"
        case .diamondSymbol: return "Diamond"
        case .heartSymbol: return "Heart"
        case .starSymbol: return "Star"
        case .cloverSymbol: return "Clover"
        case .horseshoeSymbol: return "Horseshoe"
        case .bellSymbol: return "Bell"
        case .cherrySymbol: return "Cherry"
        case .fruitSymbol: return "Fruit"
        case .grapesSymbol: return "Grapes"
        case .lemonSymbol: return "Lemon"
        case .strawberrySymbol: return "Strawberry"
        case .watermelonSymbol: return "Watermelon"
        case .questionSymbol: return "Question"
        }
    }

    // Reusable currency formatter to avoid per-row allocations
    private static let currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        return f
    }()

    private func currency(_ value: Int) -> String {
        InfoView.currencyFormatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }

    // Helper view for key-value pairs
    private func KeyValueRow(_ key: String, value: String?) -> some View {
        // Simple reusable row used in the Information section
        HStack {
            Text(key)
            Spacer()
            Text(value ?? "N/A")
        }
    }
}

struct FormRowView: View {
    var firstItem: String
    var secondItem: String
    
    var body: some View {
        HStack {
            Text(firstItem)
                .foregroundColor(Color.gray)
            Spacer()
            Text(secondItem)
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
