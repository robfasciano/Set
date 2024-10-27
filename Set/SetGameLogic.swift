//
//  SetGameLogic.swift
//  Set
//
//  Created by Robert Fasciano on 10/22/24.
//

import Foundation

struct SetGame {
    var cards: Array<Card>
    
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
    
    var cardsLeftInDeck: Int {
        var count = 0
        for i in cards {
            if !i.isDealt {
                count += 1
            }
        }
        return count
    }
    
    var faceUpCardCount: Int {
        var count = 0
        for i in cards {
            if i.isDealt && !i.isMatched { count += 1}
        }
        return count
    }

    //this are the visibly face up cards, which means we exclude matched ones
    var faceUpCards: Array<Card> {
        var tempCards:Array<Card> = []
        for i in cards {
            if i.isDealt && !i.isMatched {
                tempCards.append(i)
            }
        }
        return tempCards
    }

    
    mutating func deal(_ toDeal: Int) {
        var dealCount = 0
        for i in 0..<cards.count {
            if !cards[i].isDealt {
                cards[i].isDealt = true
                dealCount += 1
                if dealCount == toDeal {
                    return
                }
            }
        }
    }
    
    
    mutating func chooseCard(_ card: Card) {
        if numberOfSelectedCards < 3 {
            cards[indexOfChosen(card)].isSelected.toggle()
        } else {
            if matchedSetSelected() {
                removeMatch()
                deal(3)
            }
            deselectAll()
            if !cards[indexOfChosen(card)].isMatched {
                cards[indexOfChosen(card)].isSelected = true
            }
        }
    }
    
    
    mutating func deselectAll() {
        for i in cards.indices {
            cards[i].isSelected = false
        }
    }
    
    
    var numberOfSelectedCards: Int {
        var selectionCount = 0
        for i in cards {
            if i.isDealt && i.isSelected { selectionCount += 1}
        }
        return selectionCount
    }
    
    
    //MARK: funcs to check matching
    func threeCardsMatch(_ cardsToCheck: [Card]) -> Bool {
        if colorSet(cardsToCheck)
            && symbolSet(cardsToCheck)
            && shadingSet(cardsToCheck)
            && numberSet(cardsToCheck) {
            return true
        }
        return false
    }
    
    func matchedSetSelected() -> Bool {
        threeCardsMatch(getSelectedCards())
    }


    func colorSet(_ cardsSelected: [Card]) -> Bool {
        if cardsSelected[0].color == cardsSelected[1].color
            && cardsSelected[0].color == cardsSelected[2].color {
            return true
        }
        if cardsSelected[0].color != cardsSelected[1].color
            && cardsSelected[0].color != cardsSelected[2].color
            && cardsSelected[1].color != cardsSelected[2].color {
            return true
        }
        return false
    }

    func symbolSet(_ cardsSelected: [Card]) -> Bool {
        if cardsSelected[0].symbol == cardsSelected[1].symbol
            && cardsSelected[0].symbol == cardsSelected[2].symbol {
            return true
        }
        if cardsSelected[0].symbol != cardsSelected[1].symbol
            && cardsSelected[0].symbol != cardsSelected[2].symbol
            && cardsSelected[1].symbol != cardsSelected[2].symbol {
            return true
        }
        return false
    }

    func shadingSet(_ cardsSelected: [Card]) -> Bool {
        if cardsSelected[0].shading == cardsSelected[1].shading
            && cardsSelected[0].shading == cardsSelected[2].shading {
            return true
        }
        if cardsSelected[0].shading != cardsSelected[1].shading
            && cardsSelected[0].shading != cardsSelected[2].shading
            && cardsSelected[1].shading != cardsSelected[2].shading {
            return true
        }
        return false
    }

    func numberSet(_ cardsSelected: [Card]) -> Bool {
        if cardsSelected[0].count == cardsSelected[1].count
            && cardsSelected[0].count == cardsSelected[2].count {
            return true
        }
        if cardsSelected[0].count != cardsSelected[1].count
            && cardsSelected[0].count != cardsSelected[2].count
            && cardsSelected[1].count != cardsSelected[2].count {
            return true
        }
        return false
    }

    func getSelectedCards() -> [Card] {
        var returnVal: Array<Card> = []
        for i in cards {
            if i.isSelected {
                returnVal.append(i)
            }
        }
        return returnVal
    }
    
    
    var anyVisibleMatches: Bool {
        for i in 0..<faceUpCards.count {
            for j in i+1..<faceUpCards.count {
                for k in j+1..<faceUpCards.count {
                    if threeCardsMatch([faceUpCards[i], faceUpCards[j], faceUpCards[k]]) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    mutating func removeMatch() {
        for i in cards.indices {
            if cards[i].isSelected {
                cards[i].isMatched = true
                cards[i].isSelected = false
            }
        }

    }
    
    func indexOfChosen(_ card: Card) -> Int {
        var cardIndex = 0
        for i in cards {
            if i.id == card.id {
                return cardIndex
            } else {
                cardIndex += 1
            }
        }
        return 0 //FIXME: this should really handle error here
    }
    
    
    
    struct Card: Equatable, Identifiable, CustomDebugStringConvertible {
        var debugDescription: String {
            CardDebugString(self)
        }
        var isDealt = false
        var isMatched = false
        var isSelected = false
        let symbol: cardSymbol
        let count: symbolCount
        let shading: symbolShading
        let color: symbolColor
        var id: String {
            CardDebugString(self)
        }
        
        
        func CardDebugString(_ card: Card) -> String {
            var tempString = ""
            
            switch card.count {
            case .one:
                tempString.append("1")
            case .two:
                tempString.append("2")
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
