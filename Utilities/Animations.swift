//
//  Animations.swift
//  FormativeiOS
//
//  Animation Utilities
//

import SwiftUI

extension Animation {
    // Spring animations
    static let springBouncy = Animation.spring(response: 0.4, dampingFraction: 0.7)
    static let springSmooth = Animation.spring(response: 0.5, dampingFraction: 0.8)
    static let springSnappy = Animation.spring(response: 0.3, dampingFraction: 0.6)
    
    // Timing curves
    static let easeInOutStandard = Animation.easeInOut(duration: 0.3)
    static let easeOutEnter = Animation.easeOut(duration: 0.25)
    static let easeInExit = Animation.easeIn(duration: 0.2)
}

// MARK: - View Modifiers for Animations
extension View {
    func pressAnimation() -> some View {
        self.modifier(PressAnimationModifier())
    }
    
    func fadeInAnimation(delay: Double = 0) -> some View {
        self.modifier(FadeInModifier(delay: delay))
    }
}

struct PressAnimationModifier: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        withAnimation(.springSnappy) {
                            isPressed = true
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.springSnappy) {
                            isPressed = false
                        }
                    }
            )
    }
}

struct FadeInModifier: ViewModifier {
    let delay: Double
    @State private var opacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOutEnter.delay(delay)) {
                    opacity = 1.0
                }
            }
    }
}

