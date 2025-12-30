//
//  PrimaryButton.swift
//  FormativeiOS
//
//  Primary Button Component
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var icon: String? = nil
    var isLoading: Bool = false
    var isDisabled: Bool = false

    var body: some View {
        Button(action: {
            Haptics.impact(.medium)
            action()
        }) {
            HStack(spacing: .spacingS) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else if let icon = icon {
                    Image(systemName: icon)
                }

                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient.brand
            )
            .foregroundColor(.white)
            .cornerRadius(.radiusSmall)
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isLoading || isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

// MARK: - Scale Button Style (doesn't block scroll)
struct ScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.96

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Sign In", action: {})
        PrimaryButton(title: "Apply Now", action: {}, icon: "paperplane.fill")
        PrimaryButton(title: "Loading...", action: {}, isLoading: true)
        PrimaryButton(title: "Disabled", action: {}, isDisabled: true)
    }
    .padding()
}
