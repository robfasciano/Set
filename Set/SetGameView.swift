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

    var body: some View {
        VStack {
            cards.animation(.default, value: viewModel.cards)
            Spacer()
            bottomButtons
        }
        .padding()
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
    
    
    var deck: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .aspectRatio(2/3, contentMode: .fill)
                .frame(width: 45, height: 50)
                .foregroundStyle(.blue)
            Text("\(viewModel.cardsInDeck)")
                .foregroundStyle(.white).font(.largeTitle)
        }
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
        .disabled(viewModel.cardsInDeck == 0)
        .opacity(viewModel.cardsInDeck == 0 ? 0.4 : 1)
    }
}

#Preview {
    SetGameView(viewModel: BasicSetViewModel())
}
