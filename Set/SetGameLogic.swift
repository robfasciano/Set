//
//  SetGameLogic.swift
//  Set
//
//  Created by Robert Fasciano on 10/22/24.
//

import Foundation
import SwiftUICore

struct SetGame {
    var cards: Array<Card>
    var numPlayers: Int
    
    let replaceMatchedCards = false
    
    private var score: Array<Int>
    
    var activePlayer: Int? = nil

    
    init(Players numPlayers: Int) {
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
        self.numPlayers = numPlayers
        self.score = []
        for _ in 1...numPlayers {
            self.score.append(0)
        }
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
    
    func score(player: Int) -> Int {
        score[player]
    }
    
    mutating func addScore(_ player: Int, points: Int) {
        score[player] += points
    }
    
    func cardsInDiscardDeck(_ which: Int) -> Array<Card> {
        var tempCards:Array<Card> = []
        for i in cards {
            if i.isMatched && i.discardDeck == which {
                tempCards.append(i)
            }
        }
        return tempCards
    }
    
    mutating func addScoreForMatch() {
        guard let numPlayer = activePlayer else { return }
        score[numPlayer] += Constants.scoreForMatch
    }
    
    mutating func addScoreForMismatch() {
        guard let numPlayer = activePlayer else { return }
        score[numPlayer] += Constants.scoreForMismatch
    }
    
    mutating func springCard(_ card: Card) {
        cards[indexOfChosen(card)].justHit = false
    }
    
    
    //MARK: funcs to check matching
    func threeCardsMatch(_ cardsToCheck: [Card]) -> Bool {
        if cardsToCheck.count != 3 {return false}
        if colorSet(cardsToCheck)
            && symbolSet(cardsToCheck)
            && shadingSet(cardsToCheck)
            && numberSet(cardsToCheck) {
            return true
        }
        return false
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
    
//    func getSelectedCards() -> [Card] {
//        var returnVal: Array<Card> = []
//        for i in cards {
//            if i.isSelected {
//                returnVal.append(i)
//            }
//        }
//        return returnVal
//    }
    
    func card(from cardId: String) -> Card {
        for cardToCheck in cards {
            if cardToCheck.id == cardId {
                return cardToCheck
            }
        }
        return cards[0] //should never get here
    }
    
    func VisibleMatches(CardIDs: [Card.ID]) -> Int {
        var count = 0
            for i in 0..<CardIDs.count {
                for j in i+1..<CardIDs.count {
                    for k in j+1..<CardIDs.count {
                        if threeCardsMatch([card(from: CardIDs[i]), card(from: CardIDs[j]), card(from: CardIDs[k])]) {
                            count += 1
                        }
                    }
                }
            }
            return count
        }
    
//    mutating func removeMatch(player: Int) {
//        for i in cards.indices {
//            if cards[i].isSelected {
//                cards[i].isMatched = true
//                cards[i].discardDeck = player
//                cards[i].isSelected = false
//            }
//        }
//    }
    
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

    //MARK: timer funcs
    var timerStart: Date?

    var timerPercentRemaining: Double {
        timeLeft > 0 ? (timeLeft / Constants.timeToChoose ) * 100.0  : 0.0
    }

    var timeLeft: TimeInterval {
        if let timerStart {
            return Constants.timeToChoose - Date().timeIntervalSince(timerStart)
        } else {
            return Constants.timeToChoose
        }
    }

    
    struct Card: Equatable, Identifiable, CustomDebugStringConvertible {
        var debugDescription: String {
            CardDebugString(self)
        }
//        var isDealt = false
        var isMatched = false
        var discardDeck = 0 //make sure to set this when isMatched==true
//        var isSelected = false
        var justHit = false
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
                tempString.append("stripe ")
            case .filled:
                tempString.append("fill ")
            }
            
            switch card.symbol {
            case .Diamond:
                tempString.append("✦")
            case .Squiggle:
                tempString.append("⌁")
            case .Line:
                tempString.append("-")
            }
            
            return tempString
        }
    }
    
    struct Constants {
        static let timeToChoose = 6.0
        static let scoreForMatch = 1
        static let scoreForMismatch = -1
    }
    
}
