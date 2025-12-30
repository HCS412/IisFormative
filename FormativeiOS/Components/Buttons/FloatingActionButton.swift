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

    var body: some View {
        Button(action: {
            Haptics.impact(.medium)
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(LinearGradient.brand)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 15, y: 5)
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.9))
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

