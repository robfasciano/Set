//
//  BasicSetViewModel.swift
//  Set
//
//  Created by Robert Fasciano on 10/21/24.
//

import SwiftUI

class BasicSetViewModel: ObservableObject {
    
    private static func createSetGame(_ players: Int) -> SetGame {
        SetGame(Players: players)
    }

    let cardBackground: Color = .white
    let cardMatchBackground: Color = Color(red: 0.826, green: 1.00, blue: 0.870) //light green
    let cardMismatchBackground: Color = Color(red: 1.0, green: 0.909, blue: 0.926) //light red
    let cardBack: Color = Color(red: 0.384, green: 0.2, blue: 1.00) //light purple

    
    @Published private var model = createSetGame(1)
    
//    var justPressedCard: [SetGame.Card] {
//            model.faceUpCards.filter {justHit($0)}
//    }
    
    var faceUpCards: Array<SetGame.Card> {
        return model.faceUpCards
    }
    
    var activePlayer: Int? {
        model.activePlayer
    }
    
    func setActive(_ player: Int) {
        model.activePlayer = player
        model.timerStart = Date()
    }
    
    func timerDone() {
        model.addScore(model.activePlayer!, points: -1)
        model.deselectAll()
        model.activePlayer = nil
    }

    var timerPercentRemaining: CGFloat {
        get {
            if model.timerPercentRemaining <= 0 && model.activePlayer != nil {
                timerDone()
            }
            return model.timerPercentRemaining
        }
    }
    
    var cards: Array<SetGame.Card> {
        return model.cards
    }

    var anyVisibleMatches: Bool {
        return model.anyVisibleMatches
    }

    var matchedCards: Bool {
        if threeCardsSelected {
            if model.matchedSetSelected() {
                return true
            }
        }
        return false
    }

    var cardsLeftInDeck: Array<SetGame.Card> {
        model.cardsLeftInDeck
    }
 
    func cardsInDiscardDeck(_ which: Int) -> Array<SetGame.Card> {
        model.cardsInDiscardDeck(which)
    }
    
    var threeCardsSelected: Bool {
        model.getSelectedCards().count == 3
    }
    
    var numPlayers: Int {
        get { model.numPlayers }
        set {
            model.numPlayers = newValue
            model.activePlayer = nil
            model = BasicSetViewModel.createSetGame(numPlayers)
        }
    }
    
    func score(_ player: Int) -> Int {
        model.score(player: player)
    }
    
    private let dealInterval: TimeInterval = 0.5

    //MARK: Intents
    func dealCards(_ numberOfCards: Int) {
        model.deal(numberOfCards)
    }
    
    func newGame() {
        model.activePlayer = nil
        
        model = BasicSetViewModel.createSetGame(numPlayers)
    }

    func choose(_ card: SetGame.Card) {
        if model.activePlayer == nil { return }
        if model.chooseCard(card, player: model.activePlayer!) {
            model.activePlayer = nil
            if !model.anyVisibleMatches {
                print("no matches")
                model.deal(3)
            } else { print("some matches")}
        }
    }
    
    func postChoose(_ card: SetGame.Card) {
        model.springCard(card)
    }

}

