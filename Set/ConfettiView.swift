//
//  ConfettiView.swift
//  Set
//
//  Created by Robert Fasciano on 1/16/25.
//


import SwiftUI


struct TempView: View {
    @State private var showConfetti = false
    @State private var redlight = false
    
    var body: some View {
        ZStack {
            Color(.teal)
                .ignoresSafeArea()
            HStack{
                
                Button("\n\nMake it rain!\n\n") {
                    showConfetti = true
                    print("\(showConfetti ? "start" : "stop") the rain.")
                }
                Button("\n\nRedlight!\n\n") {
                    redlight.toggle()
                }
                .tint(showConfetti ? .red : .green)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.extraLarge)
            .scaleEffect(3)
        }
        .displayConfetti(isActive: $showConfetti)
    }
}

//can't seem to figure out how to combine code for these 3 functions
struct ConfettiView1: View {
    @State var animate = false
    @State var xSpeed = Double.random(in: 0.7...2)
    @State var zSpeed = Double.random(in: 1...2)
    @State var anchor = CGFloat.random(in: 0...1).rounded()
    
    var body: some View {
            Squiggle()
                .fill([Color.orange, Color.green, Color.blue, Color.red, Color.yellow].randomElement() ?? Color.green)
                .animation(.none, value: animate) //to keep colors from changing during animation
                .frame(width: [20, 30, 40].randomElement()!, height: 20)
                .onAppear(perform: { animate = true })
                .rotation3DEffect(.degrees(animate ? 360 : 0), axis: (x: 1, y: 0, z: 0))
                .animation(Animation.linear(duration: xSpeed).repeatForever(autoreverses: false), value: animate)
                .rotation3DEffect(.degrees(animate ? [-360, 360].randomElement()! : 0), axis: (x: 0, y: 0, z: 1), anchor: UnitPoint(x: anchor, y: anchor))
                .animation(Animation.linear(duration: zSpeed).repeatForever(autoreverses: false), value: animate)
    }
}

struct ConfettiView2: View {
    @State var animate = false
    @State var xSpeed = Double.random(in: 0.7...2)
    @State var zSpeed = Double.random(in: 1...2)
    @State var anchor = CGFloat.random(in: 0...1).rounded()
    
    var body: some View {
            Diamond()
                .fill([Color.orange, Color.green, Color.blue, Color.red, Color.yellow].randomElement() ?? Color.green)
                .animation(.none, value: animate) //to keep colors from changing during animation
                .frame(width: [20, 30, 40].randomElement()!, height: 20)
                .onAppear(perform: { animate = true })
                .rotation3DEffect(.degrees(animate ? 360 : 0), axis: (x: 1, y: 0, z: 0))
                .animation(Animation.linear(duration: xSpeed).repeatForever(autoreverses: false), value: animate)
                .rotation3DEffect(.degrees(animate ? [-360, 360].randomElement()! : 0), axis: (x: 0, y: 0, z: 1), anchor: UnitPoint(x: anchor, y: anchor))
                .animation(Animation.linear(duration: zSpeed).repeatForever(autoreverses: false), value: animate)
    }
}

struct ConfettiView3: View {
    @State var animate = false
    @State var xSpeed = Double.random(in: 0.7...2)
    @State var zSpeed = Double.random(in: 1...2)
    @State var anchor = CGFloat.random(in: 0...1).rounded()
    
    var body: some View {
        RoundedRectangle(cornerRadius: 9.0)
                .fill([Color.orange, Color.green, Color.blue, Color.red, Color.yellow].randomElement() ?? Color.green)
                .animation(.none, value: animate) //to keep colors from changing during animation
                .frame(width: [20, 30, 40].randomElement()!, height: 20)
                .onAppear(perform: { animate = true })
                .rotation3DEffect(.degrees(animate ? 360 : 0), axis: (x: 1, y: 0, z: 0))
                .animation(Animation.linear(duration: xSpeed).repeatForever(autoreverses: false), value: animate)
                .rotation3DEffect(.degrees(animate ? [-360, 360].randomElement()! : 0), axis: (x: 0, y: 0, z: 1), anchor: UnitPoint(x: anchor, y: anchor))
                .animation(Animation.linear(duration: zSpeed).repeatForever(autoreverses: false), value: animate)
    }
}


struct ConfettiContainerView: View {
    var count: Int = 300
    @State var yPosition: CGFloat = 0

    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { i in
                if i % 3 == 0 {
                    ConfettiView1()
                        .position(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: yPosition != 0 ? CGFloat.random(in: 0...UIScreen.main.bounds.height) : yPosition)
                } else if i % 3 == 1 {
                    ConfettiView2()
                        .position(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: yPosition != 0 ? CGFloat.random(in: 0...UIScreen.main.bounds.height) : yPosition)
                } else {
                    ConfettiView3()
                        .position(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: yPosition != 0 ? CGFloat.random(in: 0...UIScreen.main.bounds.height) : yPosition)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
//            print("     appeared!!")
            yPosition = CGFloat.random(in: 0...UIScreen.main.bounds.height)
        }
//        .onDisappear {
//            print("     gone!")
//        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
}

struct DisplayConfettiModifier: ViewModifier {
    @Binding var isActive: Bool //{
    @State private var opacity = 1.0 //{

    private let animationTime = 2.5
    private let fadeTime = 1.0
    
    func body(content: Content) -> some View {
        if !isActive {
            content
        } else {
            ZStack {
                content
                Color(.clear)
                     .overlay(ConfettiContainerView().opacity(opacity))
                    .task {
                        await handleAnimationSequence()
                    }
            }
        }
    }

    
    private func handleAnimationSequence() async {
        do {
//            print("😀 got to animation start point 1. isActive: \(isActive)")
            try await Task.sleep(nanoseconds: UInt64(animationTime * 1_000_000_000))
            withAnimation(.easeOut(duration: fadeTime)) {
                opacity = 0
//                print("🛑 got to animation stop point 2. isActive: \(isActive)")
            } completion: {
//                print("👑 complete!")
                isActive = false
                opacity = 1
            }
        } catch {
            print("😡 sleep task failed!")
        }
    }
}

extension View {
    func displayConfetti(isActive: Binding<Bool>) -> some View {
//        print("Enter: ", isActive)
        return self.modifier(DisplayConfettiModifier(isActive: isActive))
    }
}

#Preview {
        TempView()
}
