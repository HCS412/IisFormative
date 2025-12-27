//
//  Gradients.swift
//  FormativeiOS
//
//  Design System - Gradients
//

import SwiftUI

extension LinearGradient {
    // Brand gradient: Indigo → Pink
    static let brand = LinearGradient(
        colors: [Color.brandPrimary, Color.brandSecondary],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // Subtle gradient for backgrounds
    static let subtle = LinearGradient(
        colors: [
            Color.brandPrimary.opacity(0.1),
            Color.brandSecondary.opacity(0.1)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Vertical brand gradient
    static let brandVertical = LinearGradient(
        colors: [Color.brandPrimary, Color.brandSecondary],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension RadialGradient {
    // Radial brand gradient
    static let brandRadial = RadialGradient(
        colors: [Color.brandPrimary, Color.brandSecondary],
        center: .center,
        startRadius: 0,
        endRadius: 200
    )
}

// MARK: - Glass Morphism Gradient
struct GlassGradient: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.1),
                        Color.white.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
    }
}

extension View {
    func glassStyle() -> some View {
        self.modifier(GlassGradient())
    }
}

