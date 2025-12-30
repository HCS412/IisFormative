//
//  AgeVerificationView.swift
//  FormativeiOS
//
//  Age Verification Gate - App Store Requirement
//

import SwiftUI

struct AgeVerificationView: View {
    @Binding var hasVerifiedAge: Bool
    @State private var showDeclinedMessage = false

    var body: some View {
        ZStack {
            LiquidBlobBackground()
                .ignoresSafeArea()

            VStack(spacing: .spacing2XL) {
                Spacer()

                // Icon
                Image(systemName: "person.badge.shield.checkmark")
                    .font(.system(size: 70))
                    .foregroundStyle(LinearGradient.brand)

                // Title
                VStack(spacing: .spacingM) {
                    Text("Age Verification")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.adaptiveTextPrimary())

                    Text("Formative is designed for users who are 13 years of age or older.")
                        .font(.body)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, .spacingL)
                }

                // Info card
                GlassCard {
                    VStack(alignment: .leading, spacing: .spacingM) {
                        HStack(spacing: .spacingM) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.brandPrimary)
                            Text("Why we ask")
                                .fontWeight(.semibold)
                                .foregroundColor(.adaptiveTextPrimary())
                        }

                        Text("In compliance with COPPA (Children's Online Privacy Protection Act) and App Store guidelines, we require all users to confirm they meet our minimum age requirement before using the app.")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                            .lineSpacing(4)
                    }
                }
                .padding(.horizontal, .spacingL)

                Spacer()

                // Action buttons
                VStack(spacing: .spacingM) {
                    if showDeclinedMessage {
                        Text("We're sorry, but you must be 13 or older to use Formative.")
                            .font(.subheadline)
                            .foregroundColor(.error)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, .spacingL)
                    }

                    PrimaryButton(
                        title: "I am 13 or older",
                        action: {
                            Haptics.notification(.success)
                            UserDefaults.standard.set(true, forKey: "hasVerifiedAge")
                            withAnimation(.springSmooth) {
                                hasVerifiedAge = true
                            }
                        }
                    )
                    .padding(.horizontal, .spacingL)

                    Button(action: {
                        Haptics.notification(.warning)
                        withAnimation(.springSmooth) {
                            showDeclinedMessage = true
                        }
                    }) {
                        Text("I am under 13")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding(.bottom, .spacing3XL)
            }
        }
    }
}

#Preview {
    AgeVerificationView(hasVerifiedAge: .constant(false))
}
