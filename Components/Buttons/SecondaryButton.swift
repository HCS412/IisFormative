//
//  SecondaryButton.swift
//  FormativeiOS
//
//  Secondary Button Component
//

import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var icon: String? = nil
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let selection = UISelectionFeedbackGenerator()
            selection.selectionChanged()
            action()
        }) {
            HStack(spacing: .spacingS) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.clear)
            .foregroundColor(.brandPrimary)
            .overlay(
                RoundedRectangle(cornerRadius: .radiusSmall)
                    .stroke(Color.brandPrimary, lineWidth: 2)
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressed = false
                    }
                }
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        SecondaryButton(title: "Cancel", action: {})
        SecondaryButton(title: "Learn More", action: {}, icon: "arrow.right")
    }
    .padding()
}

