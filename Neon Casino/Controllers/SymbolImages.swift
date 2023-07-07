//
//  SymbolImages.swift
//  Neon Casino
//
//  Created by Kelvin Reid on 7/5/23.
//

enum SymbolImages: String {
    case bar
    case bell
    case cherry
    case clover
    case club
    case crown
    case diamond
    case fruit
    case grapes
    case heart
    case horseshoe
    case jewel
    case lemon
    case money
    case question
    case seven
    case spade
    case star
    case strawberry
    case watermelon
    case win
    
    var symbolName: String {
        switch self {
        case .bar:
            return "bar"
        case .bell:
            return "bell"
        case .cherry:
            return "cherry"
        case .clover:
            return "clover"
        case .club:
            return "club"
        case .crown:
            return "crown"
        case .diamond:
            return "diamond"
        case .fruit:
            return "fruit"
        case .grapes:
            return "grapes"
        case .heart:
            return "heart"
        case .horseshoe:
            return "horseshoe"
        case .jewel:
            return "jewel"
        case .lemon:
            return "lemon"
        case .money:
            return "money"
        case .question:
            return "question"
        case .seven:
            return "seven"
        case .spade:
            return "spade"
        case .star:
            return "star"
        case .strawberry:
            return "strawberry"
        case .watermelon:
            return "watermelon"
        case .win:
            return "win"
        }
    }
}
