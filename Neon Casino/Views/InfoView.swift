//
//  InfoView.swift
//  Slot Machine
//
//  Created by Kelvin Reid on 7/1/23.
//

import SwiftUI
import Foundation

struct InfoView: View {
    
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
                            if let sym = row.symbol {
                                Image(sym.rawValue)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Image(sym.rawValue)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Image(sym.rawValue)
                                    .resizable()
                                    .frame(width: 30, height: 30)
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
                        Image(SymbolImages.questionSymbol.rawValue)
                            .resizable().frame(width: 30, height: 30)
                        Image(SymbolImages.questionSymbol.rawValue)
                            .resizable().frame(width: 30, height: 30)
                        Image(SymbolImages.questionSymbol.rawValue)
                            .resizable().frame(width: 30, height: 30)
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
        let symbol: SymbolImages?
        let title: String
        let amount: Int?
    }

    private var payRows: [PayRow] {
        // Display order: money, jewel, crown, spade, win, other
        let ordered: [SymbolImages] = [.moneySymbol, .jewelSymbol, .crownSymbol, .spadeSymbol, .winSymbol]
        let rows = ordered.map { sym in
            let base = GameRules.payouts[sym] ?? 50
            return PayRow(symbol: sym, title: displayName(sym), amount: base)
        }
        let other = PayRow(symbol: nil, title: "Any other symbol", amount: 50)
        return rows + [other]
    }

    private func displayName(_ s: SymbolImages) -> String {
        switch s {
        case .moneySymbol: return "Money"
        case .jewelSymbol: return "Jewel"
        case .crownSymbol: return "Crown"
        case .spadeSymbol: return "Spade"
        case .winSymbol: return "Win"
        default: return s.rawValue
        }
    }

    private func currency(_ value: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        return f.string(from: NSNumber(value: value)) ?? "$\(value)"
    }

    // Helper view for key-value pairs
    private func KeyValueRow(_ key: String, value: String?) -> some View {
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
