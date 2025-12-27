//
//  FloatingActionButton.swift
//  FormativeiOS
//
//  Floating Action Button Component
//

import SwiftUI

struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    var size: CGFloat = 56
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(LinearGradient.brand)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 15, y: 5)
                .scaleEffect(isPressed ? 0.9 : 1.0)
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
    ZStack {
        Color.gray.opacity(0.2)
        VStack {
            Spacer()
            HStack {
                Spacer()
                FloatingActionButton(icon: "plus", action: {})
                    .padding()
            }
        }
    }
}

