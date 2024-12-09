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
    
    @Namespace private var dealingNamespace
    @State private var dealt: [SetGame.Card.ID] = []
    
    @Namespace private var discardNamespace
    @State private var discarded: [[SetGame.Card.ID]] = [[],[],[],[],[],[]]
    //need to differntiate discard piles somehow
    
    @State var selectedCardIDs: [SetGame.Card.ID] = []
    
    let myShape = RoundedRectangle(cornerRadius: 9)
    
    var body: some View {
        VStack {
            HStack{
                discardColumn(topPlayer: 0)
                    .animation(.linear, value: viewModel.numPlayers)
                cards //this animation is how displayed cards move when they change size
                    .animation(.easeIn(duration: 1.0), value: viewModel.cards)
                    .foregroundStyle(viewModel.cardBack)
                discardColumn(topPlayer: 1)
                    .animation(.easeInOut, value: viewModel.numPlayers)
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
                    .transition(.scale)
                Spacer()
            }
            if viewModel.numPlayers > topPlayer + 2 {
                discardPile(topPlayer + 2)
                    .transition(AsymmetricTransition(insertion: .push(from: .top), removal: .push(from: .bottom)))
                Spacer()
            }
            if viewModel.numPlayers > topPlayer + 4 {
                discardPile(topPlayer + 4)
                // .top seems to be top of entire view (almost)
                //                    .transition(AsymmetricTransition(insertion: .push(from: .top), removal: .push(from: .bottom)))
                Spacer()
            }
        }
    }
    
    @State var springCard = false
    
    private var cards: some View {
        let specialColor = matched ? viewModel.cardMatchBackground : viewModel.cardMismatchBackground
        return AspectVGrid(viewModel.cards.filter{dealt.contains($0.id)}, aspectRatio: Constants.aspectRatio) { card in
            CardView(card,
                     faceUp: true,
                     selected: selectedCardIDs.contains(card.id) && viewModel.activePlayer != nil,
                     cardColor: selectedCardIDs.contains(card.id) && selectedCardIDs.count == 3 ? specialColor : viewModel.cardBackground)
                .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                .transition(.asymmetric(insertion: .identity, removal: .identity))
            //                    .transition(.identity)
//                .scaleEffect(springCard ? 0.9 : 1)
                .padding(4)
                .onTapGesture {
                    choose(card.id)
//                    springCard = true
//                    withAnimation(.spring(response: 0.2, dampingFraction: 0.3) ) {
//                        viewModel.postChoose(card)
//                        springCard = false
//                    }
                }
        }
    }
    
    func choose(_ cardID: SetGame.Card.ID) {
        if selectedCardIDs.contains(cardID) {
            selectedCardIDs.removeAll(where: {$0 == cardID})
            return
        }
        
        if selectedCardIDs.count == 3 {
            return //should never get here, but just in case
        }
        selectedCardIDs.append(cardID)
        if selectedCardIDs.count == 3 {
            if matched {
                print("matched")
                viewModel.addScoreForMatch()
                for i in selectedCardIDs {
                    discarded[viewModel.activePlayer!].append(i)
                    dealt.removeAll(where: {$0 == i})
                    addCardsToBoard()
                }
            } else {
                print("mismatched")
                viewModel.addScoreForMismatch()
            }
            deselectAll()
        }
    }
    
    func addCardsToBoard() {
        while !viewModel.anyVisibleMatches(IDs: dealt) && cardsInDeck > 0 {
            dealCards(3)
            print("3 dealt")
        }
        
    }
    
    func deselectAll() {
        selectedCardIDs = []
        viewModel.setActivePlayer(nil)
        
    }
    
    private var matched: Bool {
        return viewModel.isMatched(viewModel.cards.filter{selectedCardIDs.contains($0.id)})
    }
    
    var bottomButtons: some View {
        VStack {
            Text("No Matches Possible").multilineTextAlignment(.center)
                .font(.largeTitle).fontWeight(.heavy)
                .foregroundStyle(viewModel.anyVisibleMatches(IDs: dealt) ? .clear : .red)
            HStack {
                VStack {
                    Text("Players").font(.largeTitle)
                    Stepper ("Player", value: $viewModel.numPlayers, in: 1...6)
                        .labelsHidden()
                        .onChange(of: viewModel.numPlayers) {
                            clearBoard()
                        }
                }
                Spacer()
                deck
                    .onTapGesture {
                        dealCards(3) //user intent
                    }
                
                Spacer()
                newGame
            }
        }
    }
    
    private let dealAnimation: Animation = .easeIn(duration: 1.40)
    private let dealInterval: TimeInterval = 0.10
    
    func dealCards(_ count: Int, delay: TimeInterval = 0) {
        var delay = delay
        var count = count
        for card in viewModel.cards.filter({
                !dealt.contains($0.id)
                && !isDiscarded($0.id)
            }) {
            if count > 0 {
                withAnimation(dealAnimation.delay(delay)) {
                    dealt.append(card.id)
                }
                count -= 1
                delay += dealInterval
            }
        }
    }
    
    
    func clearBoard() {
        dealt = []
        discarded = [[],[],[],[],[],[]]
        deselectAll()
    }
    
    var newGame: some View {
        Button(action: {
            viewModel.newGame() //user intent
            withAnimation(dealAnimation) {
                clearBoard()
            } completion: {
                dealCards(12)
                addCardsToBoard()
            }
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
                .overlay(ForEach (viewModel.cards.filter{discarded[player].contains($0.id)}) { card in
                    CardView(card, faceUp: true,
                             selected: false)
                    .foregroundStyle(viewModel.cardBack)})
                if viewModel.activePlayer == player {
                    countdown(player)
                }
            }
            
            Text("Player \(player + 1)").font(.title)
            Text("\(viewModel.score(player))").font(.largeTitle).fontWeight(.heavy)
        }
        .onTapGesture {
            deselectAll()
            viewModel.setActivePlayer(player)
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
                    .opacity(discarded[player].isEmpty ? 1.0 : Constants.discardDeckOpacity)
                    .frame(
                        width: Constants.discardDeckHeight * Constants.aspectRatio,
                        height: Constants.discardDeckHeight * (viewModel.timerPercentRemaining / 100.0))
            }
        }
    }
    
    private func isDealt(_ card: SetGame.Card) -> Bool {
        dealt.contains(card.id)
    }
    
    private func isDiscarded(_ cardID: SetGame.Card.ID) -> Bool {
        for pile in discarded {
            if pile.contains(cardID) {
                return true
            }
        }
        return false
    }
    
    var deck: some View {
        ZStack {
            myShape
                .fill(.gray)
                .frame(
                    width: Constants.drawDeckHeight * Constants.aspectRatio,
                    height: Constants.drawDeckHeight)
            ForEach(viewModel.cards.reversed(), id: \.id) { card in
                if !dealt.contains(card.id) && isDiscarded(card.id) {
                    CardView(card, faceUp: false, selected: false)
                        .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                        .transition(.scale)
                        .transition(.asymmetric(insertion: .identity, removal: .identity))
                        .frame(
                            width: Constants.drawDeckHeight * Constants.aspectRatio,
                            height: Constants.drawDeckHeight)
                }
            }
            Text("\(cardsInDeck)")
                .foregroundStyle(.white).font(.largeTitle)
        }
    }
    
    var cardsInDeck: Int {
        var count = viewModel.cards.count  - dealt.count
        for i in discarded {
            count -= i.count
        }
        return count
    }
    
}

#Preview {
    SetGameView(viewModel: BasicSetViewModel())
}
