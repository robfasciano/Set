//
//  BasicSetViewModel.swift
//  Set
//
//  Created by Robert Fasciano on 10/21/24.
//

import SwiftUI

class BasicSetViewModel: ObservableObject {
    
    private static func createSetGame() -> SetGame {
        SetGame()
    }
    
    @Published private var model = createSetGame()
    
    func cardColor(_ which: SetGame.symbolColor) -> Color {
        switch which {
        case .color1:
            return .red
        case .color2:
            return .green
        case .color3:
            return .purple
        }
    }
   
    @ViewBuilder
    func showCard (_ drawShape: SetGame.cardSymbol) -> some View {
        ZStack {
            switch drawShape {
            case .Diamond:
                Circle()
            case .Squiggle:
                Rectangle()
            case .Line:
                RoundedRectangle(cornerRadius: 50)
            }
            Text("\(model.faceUpCardCount)").foregroundStyle(.white)
        }
    }
    
    //MARK: Intents
    func dealThreeCards() {
        model.dealThree()
    }
}

