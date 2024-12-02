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
    
    let myShape = RoundedRectangle(cornerRadius: 9)

    var body: some View {
        VStack {
            HStack{
                discardColumn(topPlayer: 0)
                cards //this animation is how displayed cards move when they change size
                    .animation(.easeIn(duration: 1.0) , value: viewModel.cards)
                    .foregroundStyle(viewModel.cardBack)
                discardColumn(topPlayer: 1)
            }
            Spacer()
            bottomButtons
        }
        .padding()
    }
    
    func discardColumn(topPlayer: Int) -> some View {
        VStack {
            if viewModel.numPlayers > topPlayer {
                Spacer()
                discardPile(topPlayer)
                Spacer()
            }
            if viewModel.numPlayers > topPlayer + 2 {
                discardPile(topPlayer + 2)
                Spacer()
            }
            if viewModel.numPlayers > topPlayer + 4 {
                discardPile(topPlayer + 4)
                Spacer()
            }
        }

    }
    
    @State var springCard = false
    
    private var cards: some View {
        let specialColor = viewModel.matchedCards ? viewModel.cardMatchBackground : viewModel.cardMismatchBackground
        return AspectVGrid(viewModel.faceUpCards, aspectRatio: Constants.aspectRatio) { card in
            if isDealt(card) && !isDiscarded(card) {
                CardView(card, card.isSelected && viewModel.threeCardsSelected ? specialColor : viewModel.cardBackground)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .transition(.asymmetric(insertion: .identity, removal: .identity))
//                    .transition(.identity)
                    .scaleEffect(springCard ? 0.9 : 1)
                    .padding(4)
                    .onTapGesture {
                        viewModel.choose(card)
                        springCard = true
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.3) ) {
                            viewModel.postChoose(card)
                            springCard = false
                        }
                    }
            }
        }
    }
    
    
    var bottomButtons: some View {
        VStack {
            Text("No Matches Possible").multilineTextAlignment(.center)
                .font(.largeTitle).fontWeight(.heavy)
                .foregroundStyle(viewModel.anyVisibleMatches ? .clear : .red)
            HStack {
                VStack {
                    Text("Players").font(.largeTitle)
                    Stepper ("Player", value: $viewModel.numPlayers, in: 1...6)
                        .labelsHidden()
                }
                Spacer()
                deck
                    .onTapGesture {
                        viewModel.dealCards(3) //user intent
                        updateDealtCards()
                    }
                
                Spacer()
                newGame
            }
        }
    }
    
    private let dealAnimation: Animation = .easeIn(duration: 1.40)
    private let dealInterval: TimeInterval = 0.15
    
    func updateDealtCards(delay: TimeInterval = 0) {
        var delay = delay
        for card in viewModel.faceUpCards {
            if !dealt.contains(card.id) {
                withAnimation(dealAnimation.delay(delay)) {
                    dealt.append(card.id)
                }
                delay += dealInterval
            }
        }
    }
    
    func clearBoard() {
        withAnimation(dealAnimation) {
            dealt = []
            discarded = []
        }
    }

    
    var newGame: some View {
        Button(action: {
            viewModel.newGame() //user intent
            clearBoard()
            viewModel.dealCards(12)
            updateDealtCards(delay: 0.3)
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
                if viewModel.activePlayer == player {
                    countdown(player)
                }
            }

            Text("Player \(player + 1)").font(.title)
            Text("\(viewModel.score(player))").font(.largeTitle).fontWeight(.heavy)
        }
        .onTapGesture {
            viewModel.setActive(player)
        }
        .disabled(viewModel.activePlayer != nil)
    }


    func countdown(_ player: Int) -> some View {
        // >= 1/15 is smooth, 1 is 'click'-like
        return TimelineView(.animation(minimumInterval: 1/15)) { timeline in
            VStack(spacing: 0) { //must be inside TimelineView to keep spacing = 0
                myShape
                    .fill(.clear)
                    .frame(
                        width: Constants.discardDeckHeight * Constants.aspectRatio,
                        height: Constants.discardDeckHeight * (1 - viewModel.timerPercentRemaining / 100.0))
                myShape
                    .fill(viewModel.activePlayer == player ? .red : .clear)
                    .opacity(viewModel.cardsInDiscardDeck(player).isEmpty ? 1.0 : Constants.discardDeckOpacity)
                    .frame(
                        width: Constants.discardDeckHeight * Constants.aspectRatio,
                        height: Constants.discardDeckHeight * (viewModel.timerPercentRemaining / 100.0))
            }
        }
    }
    
    @Namespace private var dealingNamespace
    @State private var dealt: [SetGame.Card.ID] = []

    @Namespace private var discardNamespace
    @State private var discarded: [SetGame.Card.ID] = []

    private func isDealt(_ card: SetGame.Card) -> Bool {
        dealt.contains(card.id)
    }
    
    private func isDiscarded(_ card: SetGame.Card) -> Bool {
        discarded.contains(card.id)
    }
    
    var deck: some View {
        ZStack {
            myShape
                .fill(.gray)
                .frame(
                    width: Constants.drawDeckHeight * Constants.aspectRatio,
                    height: Constants.drawDeckHeight)
            ForEach(viewModel.cards.reversed(), id: \.id) { card in
                if !dealt.contains(card.id) {
                    CardView(card)
                        .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                        .transition(.asymmetric(insertion: .identity, removal: .identity))
                        .frame(
                            width: Constants.drawDeckHeight * Constants.aspectRatio,
                            height: Constants.drawDeckHeight)
                }
            }
            Text("\(viewModel.cardsLeftInDeck.count)")
                .foregroundStyle(.white).font(.largeTitle)
        }
    }
    
    
}

#Preview {
    SetGameView(viewModel: BasicSetViewModel())
}
