//
//  Cardify.swift
//  Set
//
//  Created by Robert Fasciano on 11/24/24.
//

import SwiftUI

struct Cardify: ViewModifier, Animatable {
    let isSelected: Bool
    
    init(isFaceUp: Bool, isSelected: Bool) {
        self.isFaceUp = isFaceUp
//        rotation = isFaceUp ? 0 : 180
        self.isSelected = isSelected
    }
    
    var isFaceUp: Bool //{
//        rotation < 90
//        true
//    }
    
//    var rotation: Double
//    
//    var animatableData: Double {
//        get {
//            return rotation
//        }
//        set {
//            rotation = newValue
//            print("set: \(rotation)")
//        }
//    }
    
    func body(content: Content) -> some View {
        ZStack{
            let base = RoundedRectangle(cornerRadius: Constants.cornerRadius)
            base.strokeBorder(lineWidth: isSelected ? Constants.selectedBorder : Constants.border)
                .background(base.foregroundStyle(.white))
                .overlay(content)
                .opacity(isFaceUp ? 1 : 0)
            base.fill(.blue)
                .opacity(isFaceUp ? 0 : 1)
        }
//        .rotation3DEffect(.degrees(rotation), axis: (0, 1, 0))
    }
        
        private struct Constants {
            static let cornerRadius: CGFloat = 12
            static let border: CGFloat = 3
            static let selectedBorder: CGFloat = 20
    }
}

extension View {
    func cardify(isFaceUp: Bool, isSelected: Bool) -> some View {
        modifier(Cardify(isFaceUp: isFaceUp, isSelected: isSelected))
    }
}

