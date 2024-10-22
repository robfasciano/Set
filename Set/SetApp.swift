//
//  SetApp.swift
//  Set
//
//  Created by Robert Fasciano on 10/21/24.
//

import SwiftUI

@main
struct SetApp: App {
    @StateObject var game = BasicSetViewModel()
    
    var body: some Scene {
        WindowGroup {
            SetGameView(viewModel: game)
        }
    }
}
