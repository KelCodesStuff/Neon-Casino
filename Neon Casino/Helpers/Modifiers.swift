//
//  Modifiers.swift
//  Slot Machine
//
//  Created by Kelvin Reid on 7/2/23.
//

import SwiftUI

// MARK: - Reset & info button mod
struct ButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title)
            .accentColor(Color.white)
            .padding()
    }
}

// MARK: - Jackpot number mod
struct JackpotLabelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .font(.system(size: 20, weight: .heavy, design: .rounded))
    }
}

// MARK: - Score number mod
struct ScoreNumberModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .font(.system(size: 20, weight: .heavy, design: .rounded))
    }
}

// MARK: - Score label mod
struct ScoreLabelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color.white)
            .font(.system(size: 10, weight: .bold, design: .rounded))
    }
}

// MARK: - Score capsule mod
struct ScoreCapsuleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(
                Capsule()
                    .foregroundColor(Color("ColorTransparentBlack")))
    }
}

// MARK: - Reel image mod
struct ReelImageModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scaledToFit()
            .frame(minWidth: 110, idealWidth: 110, maxWidth: 110, alignment: .center)
    }
}

// MARK: - Symbol image mod
struct SymbolImageModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scaledToFit()
            .frame(minWidth: 70, idealWidth: 70, maxWidth: 70, alignment: .center)
    }
}

// MARK: - Bet button mod
struct BetButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .aspectRatio(contentMode: .fit)
            .frame(width: 50, height: 50)
    }
}

// MARK: - Spin button mod
struct SpinButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
    }
}


