//
//  CardView.swift
//  Set
//
//  Created by Robert Fasciano on 11/24/24.
//

import SwiftUI

struct CardView: View {
    typealias Card = SetGame.Card
    
    let card: Card
    let cardBackground: Color
    
    init(_ card: Card, _ cardBackground: Color = .white) {
        self.card = card
        self.cardBackground = cardBackground
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1/15)) { timeline in //could leave off minimum interval and let swift pick, larger intervals use less battery and are more choppy
                cardContents
                .cardify(isFaceUp: card.isDealt, isSelected: card.isSelected)
                    .transition(.scale) //.opacity is default transition
        }
    }
    
    
    var cardContents: some View {
        VStack {
            switch card.count { //leaving as enums.  Maybe I will want .one to be 4 shapes? or 7?
            case .one:
                oneShape(card, cardBackground)
            case .two:
                oneShape(card, cardBackground)
                oneShape(card, cardBackground)
            case .three:
                oneShape(card, cardBackground)
                oneShape(card, cardBackground)
                oneShape(card, cardBackground)
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
                Diamond().fill(LinearGradient(colors: pattern(card, backColor),
                                              startPoint: UnitPoint(x: 0, y: 0),
                                              endPoint: UnitPoint(x: 1, y: 0)))
                .stroke(color(card), lineWidth: 4)
                .aspectRatio(Constants.shapeAspect, contentMode: .fit)
                
            case .Squiggle:
                Squiggle().fill(
                    LinearGradient(colors: pattern(card, backColor),
                                   startPoint: UnitPoint(x: 0, y: 1.5),
                                   endPoint: UnitPoint(x: 1, y: 0)))
                .stroke(color(card), lineWidth: 4)
                .rotationEffect(Angle(degrees: 25))
                .aspectRatio(Constants.shapeAspect, contentMode: .fit)
            case .Line:
                RoundedRectangle(cornerRadius: 50).fill(LinearGradient(colors: pattern(card, backColor),startPoint: UnitPoint(x: 0, y: 0), endPoint: UnitPoint(x: 1, y: 0)))
                .stroke(color(card), lineWidth: 4)
                .aspectRatio(Constants.shapeAspect, contentMode: .fit)
            }
        }
        
        
        func pattern(_ which: SetGame.Card, _ backColor: Color) -> [Color] {
            switch which.shading {
            case .open:
                return [backColor]
            case .striped:
                var colorArray = [color(card)]
                for _ in 1...Constants.numStripes {
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


private struct Constants {
    static let shapeAspect = 3.0
    static let border = 4
    static let numStripes = 20


//    struct FontSize {
//        static let largest: CGFloat = 200
//        static let smallest: CGFloat = 10
//        static let scaleFactor = smallest / largest
//    }
}


#Preview {
    //    typealias Card = SetGame.Card
    VStack {
        HStack {
            CardView(SetGame.Card(
                isDealt: true,
                isMatched: false,
                discardDeck: 0, //make sure to set this when isMatched==true
                isSelected: false,
                symbol: .Squiggle,
                count: .one,
                shading: .striped,
                color: .color1
            ))
            
            CardView(SetGame.Card(
                isDealt: true,
                isMatched: false,
                discardDeck: 0, //make sure to set this when isMatched==true
                isSelected: false,
                symbol: .Diamond,
                count: .two,
                shading: .filled,
                color: .color2
            ))
            
            CardView(SetGame.Card(
                isDealt: true,
                isMatched: false,
                discardDeck: 0, //make sure to set this when isMatched==true
                isSelected: false,
                symbol: .Line,
                count: .three,
                shading: .open,
                color: .color3
            ))
        }
        HStack {
            CardView(SetGame.Card(
                isDealt: false,
                isMatched: false,
                discardDeck: 0, //make sure to set this when isMatched==true
                isSelected: false,
                symbol: .Line,
                count: .three,
                shading: .open,
                color: .color3
            ))
        }
    }.foregroundStyle(.orange)
}
