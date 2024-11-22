//
//  SetGameView.swift
//  Set
//
//  Created by Robert Fasciano on 10/21/24.
//

import SwiftUI

struct SetGameView: View {
    
    @ObservedObject var viewModel: BasicSetViewModel

    private let aspectRatio: CGFloat = 2/3
    @State var activePlayer: Int? = nil

    var body: some View {
        VStack {
            HStack{
                discardPile(0)
                cards.animation(.default, value: viewModel.cards)
                if viewModel.numPlayers == 2 {
                    discardPile(1)
                }
            }
            Spacer()
            bottomButtons
        }
        .padding()
        .onAppear() {
            if viewModel.numPlayers == 1 {
                activePlayer = 0
            }
        }
    }


    private var cards: some View {
        let specialColor = viewModel.matchedCards ? viewModel.cardMatchBackground : viewModel.cardMismatchBackground
        return AspectVGrid(viewModel.faceUpCards, aspectRatio: aspectRatio) { card in
            CardView(card, card.isSelected && viewModel.threeCardsSelected ? specialColor : viewModel.cardBackground)
                .padding(4)
                .onTapGesture {
                    viewModel.choose(card)
                }
        }
    }

    
    struct CardView: View {
        let card: SetGame.Card
        let cardBackground: Color

        init(_ card: SetGame.Card, _ cardBackground: Color) {
            self.card = card
            self.cardBackground = cardBackground
        }
        
        var body: some View {
            ZStack{
                let base = RoundedRectangle(cornerRadius: 12)
                Group {
                    base.foregroundStyle(cardBackground)
                    base.strokeBorder(lineWidth: card.isSelected ? 10 : 3)
                        .foregroundStyle(.blue)
                    BasicSetViewModel.show(card, cardBackground)
                }
            }
            .opacity(card.isDealt || !card.isMatched ? 1 : 0)

        }
    }
    
    var bottomButtons: some View {
        HStack {
            addThree
            Spacer()
            deck
            Spacer()
            newGame
        }
    }
    
    var newGame: some View {
        Button(action: {
            viewModel.newGame() //user intent
        })
        {
            VStack{
                Image(systemName: "sparkles.rectangle.stack")
                    .font(.largeTitle)
                Text("New")
            }
        }
    }
    
    func discardPile(_ player: Int) -> some View {
        VStack {
            ZStack {
//                highlightDiscard(true)
                cardOutline(color: .blue, highlight: activePlayer == player)
                //add discard pile
            }
            Text("Player \(player + 1)").offset(x: 0, y: 20)
        }
        .onTapGesture {
            activePlayer = player
        }
    }
    
    var discardPlayer1: some View {
        VStack {
            ZStack {
                cardOutline(color: .blue, highlight: activePlayer == 1)
            }
            Text("Player 2").offset(x: 0, y: 20)
        }
        .onTapGesture {
            activePlayer = 1
        }

    }

    let myShape = RoundedRectangle(cornerRadius: 9)


    var deck: some View {
        ZStack {
            if viewModel.cardsLeftInDeck == 0 {
                cardOutline(color: .blue)
            }
            cardShape(color: .blue)
            Text("\(viewModel.cardsLeftInDeck)")
                    .foregroundStyle(.white).font(.largeTitle)
            }
        }
    

    private func cardShape(color: Color, highlight: Bool = false) -> some View {
         myShape
            .aspectRatio(2/3, contentMode: .fill)
            .frame(width: 45, height: 50)
            .scaleEffect(highlight ? 1.5 : 1)
            .foregroundStyle(color)
    }
    
    
    private func cardOutline(color: Color, highlight: Bool = false) -> some View {
        return myShape
            .fill(.gray)
            .aspectRatio(2/3, contentMode: .fill)
            .frame(width: 45, height: 50)
            .scaleEffect(highlight ? 1.5 : 1)
            .overlay(
                myShape
                    .strokeBorder(lineWidth: 5)
                    .foregroundStyle(highlight ? .red : color)
                    .aspectRatio(2/3, contentMode: .fill)
                    .frame(width: 45, height: 50)
                    .scaleEffect(highlight ? 1.5 : 1)
            )
    }

    
    var addThree: some View {
        Button(action: {
            viewModel.dealThreeCards() //user intent
        })
        {
            VStack{
                if viewModel.anyVisibleMatches {
                    Image(systemName: "rectangle.stack.badge.plus")
                        .font(.largeTitle)
                        .symbolEffect(.wiggle.left.byLayer, options: .repeat(.periodic(delay: 5.0))) //delay deoes not seem to be updateable by a change in the viewModel (unlike foreground color)
                } else {
                    Image(systemName: "rectangle.stack.badge.plus")
                        .font(.largeTitle)
                        .symbolEffect(.wiggle.left.byLayer, options: .repeat(.periodic(delay: 0.0))) //delay deoes not seem to be updateable by a change in the viewModel (unlike foreground color)
                }
                Text("Add 3")
            }
            .foregroundStyle(viewModel.anyVisibleMatches ? .blue : .red)
        }
        .disabled(viewModel.cardsLeftInDeck == 0)
        .opacity(viewModel.cardsLeftInDeck == 0 ? 0.4 : 1)
    }
}

//extension Shape {
//    static func cardFormat(highlight: Bool) -> some View {
//        .aspectRatio(2/3, contentMode: .fill)
//        .frame(width: 45, height: 50)
//        .scaleEffect(highlight ? 1.5 : 1)
//    }
//}

#Preview {
    SetGameView(viewModel: BasicSetViewModel())
}
