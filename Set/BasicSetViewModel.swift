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
    
    var faceUpCards: Array<SetGame.Card> {
        return model.faceUpCards
    }
    
    let cardBackground: Color = .white
    let cardMatchBackground: Color = Color(red: 0.826, green: 1.00, blue: 0.870) //light green
    let cardMismatchBackground: Color = Color(red: 1.0, green: 0.909, blue: 0.926) //light red


    struct show:View {
        let card: SetGame.Card
        let backColor: Color

        init(_ card: SetGame.Card, _ backColor: Color) {
            self.card = card
            self.backColor = backColor
        }
        var body: some View {
            VStack {
                switch card.count { //leaving as enums.  Maybe I will want .one to be 4?
                case .one:
                    oneShape(card, backColor)
                case .two:
                    oneShape(card, backColor)
                    oneShape(card, backColor)
                case .three:
                    oneShape(card, backColor)
                    oneShape(card, backColor)
                    oneShape(card, backColor)
                }
            }
            .padding(15)
        }
        
        
        struct oneShape: View {
            let card: SetGame.Card
            let backColor: Color
            
            init(_ card: SetGame.Card, _ backColor: Color) {
                self.card = card
                self.backColor = backColor
            }
            
            var body: some View {
                switch card.symbol {
                case .Diamond:
                    Diamond().fill(Gradient(colors: pattern(card, backColor)))
                        .stroke(color(card), lineWidth: 4)
                        .aspectRatio(3.0, contentMode: .fit)
                case .Squiggle:
                    Rectangle().fill(Gradient(colors: pattern(card, backColor)))
                        .stroke(color(card), lineWidth: 4)
                        .aspectRatio(3.0, contentMode: .fit)
                case .Line:
                    RoundedRectangle(cornerRadius: 50).fill(Gradient(colors: pattern(card, backColor)))
                        .stroke(color(card), lineWidth: 4)
                        .aspectRatio(3.0, contentMode: .fit)
                }
            }
            
            
            func pattern(_ which: SetGame.Card, _ backColor: Color) -> [Color] {
                switch which.shading {
                case .open:
                    return [backColor]
                case .striped:
                    var colorArray = [color(card)]
                    for _ in 1...4 {
                        colorArray.append(backColor)
                        colorArray.append(color(card))
                    }
                    return colorArray
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

    var cardsInDeck: Int {
        return model.cardsLeftInDeck
    }
    
    var threeCardsSelected: Bool {
        return model.getSelectedCards().count == 3
    }

    //MARK: Intents
    func dealThreeCards() {
        if model.numberOfSelectedCards == 3 {
            if model.matchedSetSelected() {
                model.removeMatch()
                model.deselectAll()
            }
        }
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

