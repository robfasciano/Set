//
//  BasicSetViewModel.swift
//  Set
//
//  Created by Robert Fasciano on 10/21/24.
//

import SwiftUI

class BasicSetViewModel: ObservableObject {
    
    private static func createSetGame() -> SetGame {
        SetGame()
    }
    
    @Published private var model = createSetGame()
    
    func cardColor(_ which: SetGame.symbolColor) -> Color {
        switch which {
        case .color1:
            return .red
        case .color2:
            return .green
        case .color3:
            return .purple
        }
    }
    
    //this are the visibly face up cards, which means we exclude matched ones
    var faceUpCards: Array<SetGame.Card> {
//        return [model.cards[1], model.cards[2]]
        //TODO: maybe more efficient to figure out how to filter correctly
//        return model.cards.indices.filter { index in
//                    model.cards[index]
        var tempCards:Array<SetGame.Card> = []
        for i in model.cards {
            if i.isFaceUp && !i.isMatched {
                tempCards.append(i)
            }
        }
        return tempCards
    }
    
    
    
    @ViewBuilder
    func showCard (_ drawShape: SetGame.cardSymbol) -> some View {
        ZStack {
            switch drawShape {
            case .Diamond:
                Circle()
            case .Squiggle:
                Rectangle()
            case .Line:
                RoundedRectangle(cornerRadius: 50)
            }
            Text("\(model.faceUpCardCount)").foregroundStyle(.white)
        }
    }
    
    //MARK: Intents
    func dealThreeCards() {
        model.dealThree()
     }
    
    func newGame() {
        model = BasicSetViewModel.createSetGame()
    }

    func choose(_ card: SetGame.Card) {
        model.chooseCard(card)
    }

}

