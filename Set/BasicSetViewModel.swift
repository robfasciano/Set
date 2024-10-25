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
    
    
    //this are the visibly face up cards, which means we exclude matched ones
    var faceUpCards: Array<SetGame.Card> {
        var tempCards:Array<SetGame.Card> = []
        for i in model.cards {
            if i.isDealt && !i.isMatched {
                tempCards.append(i)
            }
        }
        return tempCards
    }
    
    
//    @ViewBuilder
    struct show:View {
        let card: SetGame.Card
        
        init(_ card: SetGame.Card) {
            self.card = card
        }
        var body: some View {
            VStack {
                ForEach(0..<count(card)) { _ in //FIXME: unpredictable behavior,  must fix (somehow!)
                    switch card.symbol {
                    case .Diamond:
                        Circle().fill(Gradient(colors: pattern(card)))
                            .stroke(color(card), lineWidth: 4)
                            .aspectRatio(2.5, contentMode: .fit)
                    case .Squiggle:
                        Rectangle().fill(Gradient(colors: pattern(card)))
                            .stroke(color(card), lineWidth: 4)
                            .aspectRatio(3.0, contentMode: .fit)
                    case .Line:
                        RoundedRectangle(cornerRadius: 50).fill(Gradient(colors: pattern(card)))
                            .stroke(color(card), lineWidth: 4)
                            .aspectRatio(3.0, contentMode: .fit)
                    }
                }
            }
            .padding(15)
        }
      
        func pattern(_ which: SetGame.Card) -> [Color] {
            switch which.shading {
            case .open:
                return [.white]
            case .striped:
                return [color(card), .white, color(card), .white, color(card), .white, color(card), .white, color(card)]
            case .filled:
                return [color(card)]
            }
        }
        
        func color(_ which: SetGame.Card) -> Color {
            switch which.color {
            case .color1:
                return .red
            case .color2:
                return .green
            case .color3:
                return .purple
            }
        }
        
        func count(_ which: SetGame.Card) -> Int {
            switch which.count {
            case .one:
                return 1
            case .two:
                return 2
            case .three:
                return 3
            }
        }
    }
    
    var cards: Array<SetGame.Card> {
        return model.cards
    }

    
    //MARK: Intents
    func dealThreeCards() {
        model.deal(3)
     }
    
    func newGame() {
        model = BasicSetViewModel.createSetGame()
        model.deal(12)
    }

    func choose(_ card: SetGame.Card) {
        model.chooseCard(card)
    }

}

