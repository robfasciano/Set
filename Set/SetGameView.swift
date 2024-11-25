//
//  SetGameView.swift
//  Set
//
//  Created by Robert Fasciano on 10/21/24.
//

import SwiftUI

struct SetGameView: View {
    
    @ObservedObject var viewModel: BasicSetViewModel
    
    private struct Constants {
        static let aspectRatio: CGFloat = 2/3
        static let drawDeckHeight: CGFloat = 100
        static let discardDeckHeight: CGFloat = 150
        static let discardDeckOpacity: CGFloat = 0.5
        //        struct FontSize {
        //            static let largest: CGFloat = 200
        //            static let smallest: CGFloat = 10
        //            static let scaleFactor = smallest / largest
        //        }
    }
    
    var body: some View {
        VStack {
            HStack{
                VStack {
                    discardPile(0)
                    if viewModel.numPlayers > 2 {
                        Spacer()
                        discardPile(2)
                        Spacer()
                    }
                }
                cards.animation(.default, value: viewModel.cards)
                    .foregroundStyle(viewModel.cardBack)
                VStack {
                    if viewModel.numPlayers > 1 {
                        discardPile(1)
                    }
                    if viewModel.numPlayers > 3 {
                        Spacer()
                        discardPile(3)
                        Spacer()
                    }
                }
            }
            Spacer()
            bottomButtons
        }
        .padding()
        .onAppear() {
            //            if viewModel.numPlayers == 1 {
            //                viewModel.activePlayer = 0
            //            }
        }
    }
    
    
    private var cards: some View {
        let specialColor = viewModel.matchedCards ? viewModel.cardMatchBackground : viewModel.cardMismatchBackground
        return AspectVGrid(viewModel.faceUpCards, aspectRatio: Constants.aspectRatio) { card in
            CardView(card, card.isSelected && viewModel.threeCardsSelected ? specialColor : viewModel.cardBackground)
                .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                .transition(.asymmetric(insertion: .identity, removal: .identity))
                .padding(4)
                .onTapGesture {
                    viewModel.choose(card)
                }
        }
    }
    
    
    var bottomButtons: some View {
        VStack {
            Text("No Matches Possible").multilineTextAlignment(.center)
                .font(.largeTitle)
                .foregroundStyle(viewModel.anyVisibleMatches ? .clear : .red)
            HStack {
                VStack {
                    Text("Players").font(.largeTitle)
                    Stepper ("Player", value: $viewModel.numPlayers, in: 1...4)
                        .labelsHidden()
                }
                Spacer()
                deck.foregroundStyle(viewModel.cardBack)
                    .onTapGesture {
                        viewModel.dealThreeCards() //user intent
                    }
                Spacer()
                newGame
            }
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
                myShape.frame(
                    width: Constants.discardDeckHeight * Constants.aspectRatio,
                    height: Constants.discardDeckHeight)
                .overlay(myShape.fill(.gray))
                .overlay(ForEach (viewModel.cardsInDiscardDeck(player)) { card in
                    CardView(card).foregroundStyle(viewModel.cardBack)})
                myShape
                    .fill(viewModel.activePlayer == player ? .red : .clear)
                    .opacity(viewModel.cardsInDiscardDeck(player).isEmpty ? 1.0 : Constants.discardDeckOpacity)
                    .frame(
                        width: Constants.discardDeckHeight * Constants.aspectRatio,
                        height: Constants.discardDeckHeight)
                
            }
            Text("Player \(player + 1)").font(.title)
            Text("\(viewModel.score(player))").font(.largeTitle).fontWeight(.black)
        }
        .onTapGesture {
            viewModel.activePlayer = player
        }
        .disabled(viewModel.activePlayer != nil)
    }
    
    
    let myShape = RoundedRectangle(cornerRadius: 9)
    
    @Namespace private var dealingNamespace
    
    var deck: some View {
        ZStack {
            myShape.frame(
                width: Constants.drawDeckHeight * Constants.aspectRatio,
                height: Constants.drawDeckHeight)
            .overlay(myShape.fill(.gray))
            .overlay (ForEach(viewModel.cardsLeftInDeck) { card in
                CardView(card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .transition(.asymmetric(insertion: .identity, removal: .identity))
            })
            Text("\(viewModel.cardsLeftInDeck.count)")
                .foregroundStyle(.white).font(.largeTitle)
        }
        .frame(width: Constants.drawDeckHeight * Constants.aspectRatio,
               height: Constants.drawDeckHeight)
    }
    
    
    private func cardOutline(height: Int) -> some View {
        return myShape
            .fill(.gray)
            .frame(width: Constants.discardDeckHeight * Constants.aspectRatio,
                   height: Constants.discardDeckHeight)
    }
    
}

#Preview {
    SetGameView(viewModel: BasicSetViewModel())
}
