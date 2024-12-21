//
//  SetGameView.swift
//  Set
//
//  Created by Robert Fasciano on 10/21/24.
//

import SwiftUI

struct SetGameView: View {
    
    @ObservedObject var viewModel: BasicSetViewModel
    
    
    @Namespace private var dealingNamespace
    @State private var dealt: [SetGame.Card.ID] = []
    
    @Namespace private var discardNamespace
    @State private var discarded: [[SetGame.Card.ID]] = [[],[],[],[],[],[]]
    
    @State var selectedCardIDs: [SetGame.Card.ID] = []
    
    let cardShape = RoundedRectangle(cornerRadius: 9)
    
    var body: some View {
        VStack {
            HStack{
                discardColumn(topPlayer: 0)
                    .animation(.linear, value: viewModel.numPlayers)
                cards //this animation is how displayed cards move when they change size
//                    .animation(.easeIn(duration: 1.0), value: viewModel.cards)
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
        return AspectVGrid(viewModel.cards.filter{isDealt($0.id)}, aspectRatio: Constants.aspectRatio) { card in
            CardView(card,
                     faceUp: true,
                     selected: selectedCardIDs.contains(card.id) && viewModel.activePlayer != nil,
                     cardColor: selectedCardIDs.contains(card.id) && selectedCardIDs.count == 3 ? specialColor : viewModel.cardBackground)
            .matchedGeometryEffect(id: card.id, in: dealingNamespace)
            .transition(.asymmetric(insertion: .identity, removal: .identity))
//            .transition(.identity)
            .padding(4) //should this be accounted for in aspectvgrid?
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
        if viewModel.activePlayer == nil { return }
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
                viewModel.addScoreForMatch()
                for i in selectedCardIDs {
                    discarded[viewModel.activePlayer!].append(i)
                    dealt.removeAll(where: {$0 == i})
                    addCardsToBoard()
                }
            } else {
                viewModel.addScoreForMismatch()
            }
            deselectAll()
        }
    }
    
    func addCardsToBoard() {
        while !viewModel.anyVisibleMatches(IDs: dealt) && numCardsInDeck > 0 {
            dealCards(Constants.incrementalDealCount)
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
                    Stepper ("Player", value: $viewModel.numPlayers, in: 1...discarded.count)
                        .labelsHidden()
                        .onChange(of: viewModel.numPlayers) {
                            withAnimation(dealAnimation) {
                                clearBoard()
                            }
                        }
                }
                Spacer()
                deck
                Spacer()
                newGame
            }
        }
    }
    
    private let dealAnimation: Animation = .easeIn(duration: Constants.deal.speed)
    private let dealInterval: TimeInterval = Constants.deal.interval
    
    func dealCards(_ count: Int) {
        var delay: TimeInterval = 0
        var count = count
        
        
        //        withAnimation(.default.delay(delay)) {
        for card in viewModel.cards.filter({
                !isDealt($0.id)
            && !isDiscarded($0.id)
        }) {
            if count > 0 {
                withAnimation(dealAnimation.delay(delay)) {
//                    let temp = isDealt(card.id)
                    dealt.append(card.id) //with animation around this does not give desired effect
//                    print(temp, card.id, isDealt(card.id))
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
            withAnimation(dealAnimation) {
                clearBoard()
            } completion: {
                viewModel.newGame() //user intent
//                dealCards(1)
                dealCards(Constants.newDealCount)
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
                cardShape.frame(
                    width: Constants.discardDeck.height * Constants.aspectRatio,
                    height: Constants.discardDeck.height)
                .overlay(cardShape.fill(.gray))
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
                cardShape
                    .fill(.clear)
                    .frame(
                        width: Constants.discardDeck.height * Constants.aspectRatio,
                        height: Constants.discardDeck.height * (1 - viewModel.timerPercentRemaining / 100.0))
                cardShape
                    .fill(viewModel.activePlayer == player ? .red : .clear)
                    .opacity(discarded[player].isEmpty ? 1.0 : Constants.discardDeck.opacity)
                    .frame(
                        width: Constants.discardDeck.height * Constants.aspectRatio,
                        height: Constants.discardDeck.height * (viewModel.timerPercentRemaining / 100.0))
            }
        }
    }
    
    private func isDealt(_ cardID: SetGame.Card.ID) -> Bool {
        dealt.contains(cardID)
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
            cardShape
                .fill(.gray)
                .frame(
                    width: Constants.drawDeckHeight * Constants.aspectRatio,
                    height: Constants.drawDeckHeight)
                .overlay(
                    ForEach(viewModel.cards.filter{!isDealt($0.id) && !isDiscarded($0.id)}) { card in
                        CardView(card, faceUp: false, selected: false)
                            .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                            .transition(.asymmetric(insertion: .identity, removal: .identity))
                    })
            Text("\(numCardsInDeck)")
                .foregroundStyle(.white).font(.largeTitle)
        }
        .onTapGesture {
            if viewModel.activePlayer == nil {
//                dealCards(1) //user intent
                    dealCards(Constants.incrementalDealCount) //user intent
            }
        }
        
    }
    
    var numCardsInDeck: Int {
        var count = viewModel.cards.count  - dealt.count
        for i in discarded {
            count -= i.count
        }
        return count
    }
    
    private struct Constants {
        static let newDealCount = 12
        static let incrementalDealCount = 3
        static let aspectRatio: CGFloat = 2/3
        static let drawDeckHeight: CGFloat = 100
        struct deal {
            static let speed = 0.4
            static let interval = 0.15
        }
        struct discardDeck {
            static let height: CGFloat = 150
            static let opacity: CGFloat = 0.5
        }
        //        struct FontSize {
        //            static let largest: CGFloat = 200
        //            static let smallest: CGFloat = 10
        //            static let scaleFactor = smallest / largest
        //        }
    }

}

#Preview {
    SetGameView(viewModel: BasicSetViewModel())
}
