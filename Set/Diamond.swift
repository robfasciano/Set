//
//  Diamond.swift
//  Set
//
//  Created by Robert Fasciano on 11/15/24.
//

import SwiftUI
import CoreGraphics

struct Diamond: Shape {

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let diamondHeight = rect.height
        let diamondWidth = rect.width
        let top = CGPoint(x: center.x, y: center.y - diamondHeight / 2.0)
        let bottom = CGPoint(x: center.x, y: center.y + diamondHeight / 2.0)
        let right = CGPoint(x: center.x + diamondWidth / 2.0, y: center.y)
        let left = CGPoint(x: center.x - diamondWidth / 2.0, y: center.y)

        var p = Path()
        p.move(to: top)
        p.addLine(to: right)
        p.addLine(to: bottom)
        p.addLine(to: left)
        p.addLine(to: top)
        return p
    }
    
    
}
