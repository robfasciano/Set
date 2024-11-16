//
//  Squiggle.swift
//  Set
//
//  Created by Robert Fasciano on 11/15/24.
//

import SwiftUI
import CoreGraphics

struct Squiggle: Shape {

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let squiggleHeight = rect.height
        let squiggleWidth = rect.width
        let radius = 1.7 * min(squiggleWidth / 8, squiggleHeight / 6)
        let A = CGPoint(x: center.x + radius, y: center.y - 2*radius)
        let B = CGPoint(x: center.x + 3*radius, y: center.y - 2*radius)
        let C = CGPoint(x: center.x - radius, y: center.y + 2*radius)
        let D = CGPoint(x: center.x - 3*radius, y: center.y + 2*radius)
        let start = CGPoint(x: center.x + radius, y: center.y - radius)

        var p = Path()
        p.move(to: start)
        p.addArc(
            center: A,
            radius: radius,
            startAngle: .degrees(90),
            endAngle: .degrees(0),
            clockwise: true
        )
        p.addArc(
            center: B,
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        p.addArc(
            center: A,
            radius: 3*radius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        p.addLine(to: CGPoint(x: center.x - radius, y: center.y + radius))
        p.addArc(
            center: C,
            radius: radius,
            startAngle: .degrees(270),
            endAngle: .degrees(180),
            clockwise: true
        )
        p.addArc(
            center: D,
            radius: radius,
            startAngle: .degrees(0),
            endAngle: .degrees(180),
            clockwise: false
        )
        p.addArc(
            center: C,
            radius: 3*radius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        p.addLine(to: start)
        return p
    }
    
}

#Preview {
    Squiggle().aspectRatio(0.7, contentMode: .fit)
        .rotationEffect(Angle(degrees: 25))
}
