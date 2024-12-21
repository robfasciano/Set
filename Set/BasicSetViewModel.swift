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
        
    var activePlayer: Int? {
            model.activePlayer
    }
    
    func setActivePlayer(_ player: Int?) {
        model.activePlayer = player
        model.timerStart = Date()
    }
    
    private func timerDone() {
        model.addScore(model.activePlayer!, points: -1)
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
        model.cards
    }

    func isMatched(_ cards: [SetGame.Card]) -> Bool {
        model.threeCardsMatch(cards)
    }
    
    func anyVisibleMatches(IDs: [SetGame.Card.ID]) -> Bool {
        model.anyVisibleMatches(CardIDs: IDs)
    }

    //TODO: I think I could make numPlayers a let in logic
    var numPlayers: Int {
        get { model.numPlayers }
        set {
            model.numPlayers = newValue
            model.activePlayer = nil
            model = BasicSetViewModel.createSetGame(newValue)
        }
    }
    
    func addScoreForMatch() {
        model.addScoreForMatch()
    }
    func addScoreForMismatch() {
        model.addScoreForMismatch()
    }

    func score(_ player: Int) -> Int {
        model.score(player: player)
    }
    
    //MARK: Intents
    func newGame() {
        model.activePlayer = nil
        model = BasicSetViewModel.createSetGame(numPlayers)
    }
    
    func postChoose(_ card: SetGame.Card) {
        model.springCard(card)
    }

}

