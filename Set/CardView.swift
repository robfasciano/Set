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
    let isSelected: Bool
    let cardBackground: Color
    
    init(_ card: Card, faceUp: Bool, selected: Bool, cardColor: Color = .white) {
        self.card = card
        rotation = faceUp ? 0 : 180
        self.isSelected = selected
        self.cardBackground = cardColor
    }
    
    var isFaceUp: Bool {
        rotation < 90
//        true
    }

    var rotation: Double
    
    var animatableData: Double {
        get {
            return rotation
        }
        set {
            rotation = newValue
            print("set: \(rotation)")
        }
    }

    

    
    //what is this animation wrapper used for?  maybe card flip?
    var body: some View {
//        TimelineView(.animation(minimumInterval: 1/15)) { timeline in //could leave off minimum interval and let swift pick, larger intervals use less battery and are more choppy
//        withAnimation {
                cardContents
                .cardify(isFaceUp: isFaceUp, isSelected: isSelected)
//                .rotation3DEffect(.degrees(rotation), axis: (0,1,0))
//                .transition(.blurReplace) //.opacity is default transition
//        }
//        }
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

}


#Preview {
    //    typealias Card = SetGame.Card
    VStack {
        HStack {
            CardView(SetGame.Card(
//                isDealt: true,
                isMatched: false,
                discardDeck: 0, //make sure to set this when isMatched==true
//                isSelected: false,
                symbol: .Squiggle,
                count: .one,
                shading: .striped,
                color: .color1
            ), faceUp: true, selected: false).aspectRatio(3/4, contentMode: .fit)
            
            CardView(SetGame.Card(
//                isDealt: true,
                isMatched: false,
                discardDeck: 0, //make sure to set this when isMatched==true
//                isSelected: false,
                symbol: .Diamond,
                count: .two,
                shading: .filled,
                color: .color2
            ), faceUp: true, selected: false).aspectRatio(3/4, contentMode: .fit)
            
            CardView(SetGame.Card(
//                isDealt: true,
                isMatched: false,
                discardDeck: 0, //make sure to set this when isMatched==true
//                isSelected: false,
                symbol: .Line,
                count: .three,
                shading: .open,
                color: .color3
            ), faceUp: true, selected: false).aspectRatio(3/4, contentMode: .fit)
        }
        HStack {
            CardView(SetGame.Card(
//                isDealt: false,
                isMatched: false,
                discardDeck: 0, //make sure to set this when isMatched==true
//                isSelected: false,
                symbol: .Line,
                count: .two,
                shading: .open,
                color: .color1
            ), faceUp: false, selected: false).aspectRatio(3/4, contentMode: .fit)
            CardView(SetGame.Card(
//                isDealt: true,
                isMatched: false,
                discardDeck: 0, //make sure to set this when isMatched==true
//                isSelected: true,
                symbol: .Line,
                count: .two,
                shading: .open,
                color: .color2
            ), faceUp: true, selected: true).aspectRatio(3/4, contentMode: .fit)
            CardView(SetGame.Card(
//                isDealt: true,
                isMatched: false,
                discardDeck: 0, //make sure to set this when isMatched==true
//                isSelected: true,
                symbol: .Squiggle,
                count: .three,
                shading: .filled,
                color: .color3
            ), faceUp: true, selected: true).aspectRatio(3/4, contentMode: .fit)
        }
    }.foregroundStyle(.orange)
        .padding(20)
        
}
