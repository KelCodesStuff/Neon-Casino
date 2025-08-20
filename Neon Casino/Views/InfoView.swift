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
                Section(header: Text("Payouts (bet multiplied by win)")) {
                    ForEach(payRows) { row in
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
                                Text(currency(amt))
                            }
                        }
                    }
                }
                Section(header: Text("Jackpot")) {
                    Text("All nine Win symbols = Progressive Jackpot awarded")
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
        let symbol: SymbolImages?   // nil for the "Any other symbol" row
        let title: String           // Localized display title
        let amount: Int?            // Base payout (before bet multiplier), nil for non-payout rows
    }

    private var payRows: [PayRow] {
        // Display order: money, jewel, crown, spade, win, other
        let ordered: [SymbolImages] = [.moneySymbol, .jewelSymbol, .crownSymbol, .spadeSymbol, .winSymbol]
        let rows = ordered.map { sym in
            let base = GameRules.payouts[sym] ?? 50
            return PayRow(symbol: sym, title: displayName(sym), amount: base)
        }
        let other = PayRow(symbol: nil, title: "Any other symbol", amount: GameRules.defaultPayout)
        return rows + [other]
    }

    private func displayName(_ s: SymbolImages) -> String {
        // Human-friendly names for the known symbols. Fallback to raw asset name for others
        switch s {
        case .moneySymbol: return "Money"
        case .jewelSymbol: return "Jewel"
        case .crownSymbol: return "Crown"
        case .spadeSymbol: return "Spade"
        case .winSymbol: return "Win"
        default: return s.rawValue
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
