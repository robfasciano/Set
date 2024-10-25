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
        AspectVGrid(viewModel.faceUpCards, aspectRatio: aspectRatio) { card in
            CardView(card)
                .padding(4)
                .onTapGesture {
                    viewModel.choose(card)
                }
        }
    }

    
    struct CardView: View {
        let card: SetGame.Card
        
        init(_ card: SetGame.Card) {
            self.card = card
        }
        
        var body: some View {
            ZStack{
                let base = RoundedRectangle(cornerRadius: 12)
                Group {
                    base.foregroundStyle(.white)
                    base.strokeBorder(lineWidth: card.isSelected ? 10 : 3)
                        .foregroundStyle(.orange)
                    BasicSetViewModel.show(card)
                }
                .opacity(card.isDealt ? 1 : 0)
                base.opacity(card.isDealt ? 0 : 1)
            }
            .opacity(card.isDealt || !card.isMatched ? 1 : 0)
        }
    }
    
    var bottomButtons: some View {
        HStack {
            addThree
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
    
    var addThree: some View {
        Button(action: {
            viewModel.dealThreeCards() //user intent
        })
        {
            VStack{
                Image(systemName: "rectangle.stack.badge.plus")
                    .font(.largeTitle)
                    .symbolEffect(.wiggle.left.byLayer, options: .repeat(.periodic(delay: 2.0)))
                Text("Add 3")
            }
        }
    }
}

#Preview {
    SetGameView(viewModel: BasicSetViewModel())
}
