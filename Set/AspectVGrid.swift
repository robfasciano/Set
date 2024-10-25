//
//  AspectVGrid.swift
//  Set
//
//  Created by Robert Fasciano on 10/20/24.
//

import SwiftUI

struct AspectVGrid<Item: Identifiable, ItemView: View>: View {
    var items: [Item]
    var aspectRatio: CGFloat = 1
    var content: (Item) -> ItemView
    
    
    init(_ items: [Item], aspectRatio: CGFloat, @ViewBuilder content: @escaping (Item) -> ItemView) {
        self.items = items
        self.aspectRatio = aspectRatio
        self.content = content
    }
    
    let minGridWidth: CGFloat = 90
    
    var body: some View {
        GeometryReader { geometry in
            let gridItemSize = gridWidthThatFits(
                count: items.count,
                size: geometry.size,
                atAspectRatio: aspectRatio
            )
            
//TODO: this totally works, but there is redundant code.  Maybe I can clean this up
            if (gridItemSize == minGridWidth) {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: gridItemSize), spacing: 0)], spacing: 0) {
                        ForEach(items) { item in
                            content(item) //creates a view from an item
                                .aspectRatio(aspectRatio, contentMode: .fit)
                        }
                    }
                }
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: gridItemSize), spacing: 0)], spacing: 0) {
                    ForEach(items) { item in
                        content(item) //creates a view from an item
                            .aspectRatio(aspectRatio, contentMode: .fit)
                    }
                }
            }
        }
    }
    
    
    func gridWidthThatFits (
        count: Int,
        size: CGSize,
        atAspectRatio aspectRatio: CGFloat
    ) -> CGFloat {
        
        let count = CGFloat(count)
        var columnCount = 1.0
        var returnValue = 0.0
        repeat {
            let width = size.width / columnCount
            let height = width / aspectRatio
            
            let rowCount = (count / columnCount).rounded(.up)
            if rowCount * height < size.height {
                returnValue = max((size.width / columnCount).rounded(.down), minGridWidth)
                return returnValue
            }
            columnCount += 1
            
        } while columnCount < count
        returnValue =  max(min(size.width / count, size.height * aspectRatio).rounded(.down), minGridWidth)
        return returnValue
    }
    
}



