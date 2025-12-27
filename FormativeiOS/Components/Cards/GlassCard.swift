//
//  GlassCard.swift
//  FormativeiOS
//
//  Glass Morphism Card Component
//

import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = .radiusLarge
    
    init(cornerRadius: CGFloat = .radiusLarge, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(.spacingL)
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
                RoundedRectangle(cornerRadius: cornerRadius)
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
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
    }
}

#Preview {
    GlassCard {
        VStack(alignment: .leading, spacing: 12) {
            Text("Glass Card")
                .font(.title2)
            Text("This is a beautiful glass morphism card with gradient borders and subtle shadows.")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
    .padding()
    .background(
        LinearGradient(
            colors: [Color.brandPrimary.opacity(0.2), Color.brandSecondary.opacity(0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}

