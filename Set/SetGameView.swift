//
//  SetGameView.swift
//  Set
//
//  Created by Robert Fasciano on 10/21/24.
//

import SwiftUI

struct SetGameView: View {
    
    @ObservedObject var viewModel: BasicSetViewModel

    var body: some View {
        VStack {
            viewModel.showCard(.Diamond)
            Image(systemName: "rectangle.stack.badge.plus")
            Spacer()
            bottomButtons
        }
        .padding()
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
//        viewModel.shuffle() //user intent
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
//        viewModel.shuffle() //user intent
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


#Preview {
    SetGameView(viewModel: BasicSetViewModel())
}
