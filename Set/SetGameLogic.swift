//
//  SetGameLogic.swift
//  Set
//
//  Created by Robert Fasciano on 10/22/24.
//

import Foundation

struct SetGame {
    private(set) var cards: Array<Card>
    
    init() {
//        init(cards: Array<Card>) {
        cards = []
        for localSymbol: cardSymbol in [.Diamond, .Line, .Squiggle] {
            for localCount: symbolCount in [.one, .two, .three] {
                for localShading: symbolShading in [.open, .striped, .filled] {
                    for localColor: symbolColor in [.color1, .color2, .color3] {
                        cards.append(Card(
                            symbol: localSymbol,
                            count: localCount,
                            shading: localShading,
                            color: localColor
                        ))
                    }
                }
            }
        }
        cards.shuffle()
//        print(cards)
    }
    
    
    enum cardSymbol {
        case Diamond
        case Squiggle
        case Line
    }
    
    enum symbolCount {
        case one
        case two
        case three
    }
    
    enum symbolShading {
        case open
        case striped
        case filled
    }
    
    enum symbolColor {
        case color1
        case color2
        case color3
    }
    
    var faceUpCardCount: Int {
        var count = 0
        for i in cards {
            if i.isFaceUp { count += 1}
        }
        return count
    }
    
    mutating func dealThree() {
        let startCard = faceUpCardCount
        if startCard + 2 >= cards.count {
            return
        }
        for i in 0..<3 {
            cards[startCard + i].isFaceUp = true
        }
    }
    
    struct Card: CustomDebugStringConvertible {
        var debugDescription: String {
            CardDebugString(self)
        }
        var isFaceUp = false
        var isMatched = false
        let symbol: cardSymbol
        let count: symbolCount
        let shading: symbolShading
        let color: symbolColor
        
        
        func CardDebugString(_ card: Card) -> String {
            var tempString = "\r\n"
            
            switch card.count {
            case .one:
                tempString.append("1 ")
            case .two:
                tempString.append("2 ")
            case .three:
                tempString.append("3")
            }
            
            switch card.color {
            case .color1:
                tempString.append("🟥 ")
            case .color2:
                tempString.append("🟩 ")
            case .color3:
                tempString.append("🟪 ")
            }
            
            switch card.shading {
            case .open:
                tempString.append("open ")
            case .striped:
                tempString.append("striped ")
            case .filled:
                tempString.append("filled ")
            }
            
            switch card.symbol {
            case .Diamond:
                tempString.append("✦")
            case .Squiggle:
                tempString.append("⌁")
            case .Line:
                tempString.append("⎯")
            }

            return tempString
        }
    }
}
