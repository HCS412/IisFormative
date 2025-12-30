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

    var body: some View {
        Button(action: {
            Haptics.selection()
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
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    VStack(spacing: 20) {
        SecondaryButton(title: "Cancel", action: {})
        SecondaryButton(title: "Learn More", action: {}, icon: "arrow.right")
    }
    .padding()
}
