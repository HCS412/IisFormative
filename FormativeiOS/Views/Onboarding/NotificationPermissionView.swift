//
//  NotificationPermissionView.swift
//  FormativeiOS
//
//  Notification Permission Request View
//

import SwiftUI

struct NotificationPermissionView: View {
    @Binding var isPresented: Bool
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var isRequesting = false

    var body: some View {
        ZStack {
            Color.adaptiveBackground()
                .ignoresSafeArea()

            VStack(spacing: .spacing2XL) {
                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(LinearGradient.brand.opacity(0.2))
                        .frame(width: 120, height: 120)

                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(LinearGradient.brand)
                }

                // Title and description
                VStack(spacing: .spacingM) {
                    Text("Stay Updated")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.adaptiveTextPrimary())

                    Text("Enable notifications to receive updates about new messages, collaboration opportunities, and important account information.")
                        .font(.body)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, .spacingL)
                }

                // Benefits list
                GlassCard {
                    VStack(alignment: .leading, spacing: .spacingM) {
                        NotificationBenefitRow(
                            icon: "message.fill",
                            title: "New Messages",
                            description: "Get notified when brands and creators message you"
                        )

                        NotificationBenefitRow(
                            icon: "briefcase.fill",
                            title: "Opportunities",
                            description: "Be the first to know about new collaborations"
                        )

                        NotificationBenefitRow(
                            icon: "star.fill",
                            title: "Updates",
                            description: "Application status changes and important alerts"
                        )
                    }
                }
                .padding(.horizontal, .spacingL)

                Spacer()

                // Action buttons
                VStack(spacing: .spacingM) {
                    PrimaryButton(
                        title: "Enable Notifications",
                        action: {
                            Task {
                                isRequesting = true
                                _ = await notificationManager.requestAuthorization()
                                isRequesting = false
                                isPresented = false
                            }
                        },
                        isLoading: isRequesting
                    )
                    .padding(.horizontal, .spacingL)

                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Maybe Later")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding(.bottom, .spacing3XL)
            }
        }
    }
}

struct NotificationBenefitRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: .spacingM) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.brandPrimary)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.adaptiveTextPrimary())

                Text(description)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

#Preview {
    NotificationPermissionView(isPresented: .constant(true))
}
