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
    
    @State var showXXX = false
    @State var spinCard = false
    
    @State var showExtraTimeButton = false
    @State var ShowRemoveCardButton = false
    
    private let advancedMode = true
    
    let cardShape = RoundedRectangle(cornerRadius: 9)
    
    var body: some View {
        ZStack {
            VStack {
                HStack{
                    discardColumn(topPlayer: 0)
                        .animation(.linear, value: viewModel.numPlayers)
                    cards //this animation is how displayed cards move when they change size
                        .foregroundStyle(viewModel.cardBack)
                    discardColumn(topPlayer: 1)
                        .animation(.easeInOut, value: viewModel.numPlayers)
                }
                Spacer()
                bottomButtons
            }
            .padding()
            Text(viewModel.displayString)
                .font(.largeTitle)
                .fontWeight(.black)
                .scaleEffect(showXXX ? 150 : 0)
                .opacity(showXXX ? 0 : 1)
                .multilineTextAlignment(.center)
                .foregroundStyle(.red)
        }
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
                // .transition(AsymmetricTransition(insertion: .push(from: .top), removal: .push(from: .bottom)))
                Spacer()
            }
        }
    }
    
//    @State var springCard = false
    
    private var cards: some View {
        let specialColor = matched ? viewModel.cardMatchBackground : viewModel.cardMismatchBackground
        return AspectVGrid(viewModel.cards.filter{isDealt($0.id)}, aspectRatio: Constants.aspectRatio) { card in
            CardView(card,
                     faceUp: true,
                     selected: selectedCardIDs.contains(card.id) && viewModel.activePlayer != nil,
                     cardColor: selectedCardIDs.contains(card.id) && selectedCardIDs.count == 3 ? specialColor : viewModel.cardBackground)
            //matched

            .overlay(Text (viewModel.activePlayer != nil
                           && viewModel.markedCards.contains(card.id) ? Constants.hint.symbol : "")
                .font(.system(size: 100))
                .shadow(color: .black, radius: 10)
//                .minimumScaleFactor(0.001)
            )


            .rotationEffect(Angle(degrees: spinCard &&  selectedCardIDs.contains(card.id) ? 720 : 0))
            .scaleEffect (spinCard &&  selectedCardIDs.contains(card.id) ? 1.25 : 1)
            
            
//            .zIndex(spinCard &&  selectedCardIDs.contains(card.id) ? 10 : 1)
            .matchedGeometryEffect(id: card.id, in: dealingNamespace)
            .matchedGeometryEffect(id: card.id, in: discardNamespace)
            .transition(.asymmetric(insertion: .identity, removal: .identity))
//            .transition(.identity)
            .padding(4) //should this be accounted for in aspectvgrid?
            .onTapGesture {
                choose(card.id)
            }
        }
    }
    
    func choose(_ cardID: SetGame.Card.ID) {
        guard let playerNum = viewModel.activePlayer else { return }
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
                viewModel.setActivePlayer(nil)
                withAnimation(.easeInOut(duration: 2.0)) {
                    spinCard = true
                } completion: {
                    spinCard = false
                    withAnimation(dealAnimation) {
                        for i in selectedCardIDs {
                            discarded[playerNum].append(i)
                            dealt.removeAll(where: {$0 == i})
                        }
                        addCardsToBoard()
                    }
                    deselectAll()
                }
            } else {
                viewModel.displayString = Constants.mismatchString
                withAnimation(.easeIn(duration: 0.9)) {
                    showXXX = true
                } completion: {
                    showXXX = false
                    deselectAll()
                    viewModel.displayString = Constants.timeOverString
                }
                viewModel.addScoreForMismatch()
            }
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
        viewModel.clearMarkedCards()
    }
    
    private var matched: Bool {
        return viewModel.isMatched(viewModel.cards.filter{selectedCardIDs.contains($0.id)})
    }
    
    var bottomButtons: some View {
        VStack {
            Text(viewModel.anyVisibleMatches(IDs: dealt) ? "\(viewModel.numberOfVisibleMatches(IDs: dealt)) Matches Possible" : "No Matches Possible")
                .multilineTextAlignment(.center)
                .font(.largeTitle).fontWeight(.heavy)
                .foregroundStyle(viewModel.anyVisibleMatches(IDs: dealt) ? .blue : .red)
                .animation(.easeInOut, value: dealt)
            ZStack {
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
                    newGame
                }
                deck

                HStack {
                    Spacer()
                    extraTime
                    Spacer()
                    Spacer()
                    removeCard
                    Spacer()

                }
            }
        }
    }
    
    
    var extraTime: some View {
        Button(action: {
            withAnimation(dealAnimation) {
                showExtraTimeButton = false
                viewModel.addTime()
            }
        })
        {
            VStack{
                if showExtraTimeButton && viewModel.activePlayer != nil {
                    Text("+⏰")
                        .font(.system(size: 70))
                        .fontWeight(.black)
                    
                }
            }
        }
    }
    
    
    var removeCard: some View {
        Button(action: {
            viewModel.setMarkedCards(IDs: dealt, count: Constants.hint.count)
            withAnimation(dealAnimation) {
                ShowRemoveCardButton = false
            }
        })
        {
            VStack{
                if ShowRemoveCardButton && viewModel.activePlayer != nil {
                    Image(systemName: "minus.diamond.fill")
                        .font(.system(size: 40))
                        .fontWeight(.black)
                        .cardify(isFaceUp: true, isSelected: false, background: .white)
                        .frame(
                            width: Constants.drawDeckHeight * Constants.aspectRatio,
                            height: Constants.drawDeckHeight)
                }
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
        showExtraTimeButton = false
        ShowRemoveCardButton = false

    }
    
    var newGame: some View {
        Button(action: {
            withAnimation(dealAnimation) {
                clearBoard()
            } completion: {
                viewModel.newGame() //user intent
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
                    .foregroundStyle(viewModel.cardBack)
                    .matchedGeometryEffect(id: card.id, in: discardNamespace)
                    .transition(.asymmetric(insertion: .identity, removal: .identity))
                }
                )
                if viewModel.activePlayer == player {
                    countdown(player)
                }
            }
            Text("Player \(player + 1)").font(.title)
            Text("\(viewModel.score(player))").font(.largeTitle).fontWeight(.heavy)
                .animation(.easeInOut(duration: 2.0))
        }
        .onTapGesture {
            deselectAll()
            viewModel.setActivePlayer(player)
            showExtraTimeButton = advancedMode
            ShowRemoveCardButton = advancedMode
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
                .fontWeight(.bold)
        }
        .onTapGesture {
            if viewModel.activePlayer == nil {
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
        static let mismatchString = "☠️☠️☠️"
        static let timeOverString = "⏰⏰⏰"
        struct hint {
            static let symbol = "👎"
            static let count = 2
        }
    }

}

#Preview {
    SetGameView(viewModel: BasicSetViewModel())
}
