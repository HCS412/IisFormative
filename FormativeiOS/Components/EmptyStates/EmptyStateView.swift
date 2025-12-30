//
//  EmptyStateView.swift
//  FormativeiOS
//
//  Empty State Component
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    var secondaryActionTitle: String? = nil
    var secondaryAction: (() -> Void)? = nil

    @State private var hasAppeared = false

    var body: some View {
        VStack(spacing: .spacingXL) {
            // Icon with gradient background circle
            ZStack {
                Circle()
                    .fill(LinearGradient.brand.opacity(0.1))
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(LinearGradient.brand.opacity(0.05))
                    .frame(width: 160, height: 160)

                Image(systemName: icon)
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(LinearGradient.brand)
                    .symbolEffect(.bounce, value: hasAppeared)
            }
            .scaleEffect(hasAppeared ? 1.0 : 0.8)
            .opacity(hasAppeared ? 1.0 : 0)

            VStack(spacing: .spacingM) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.adaptiveTextPrimary())

                Text(message)
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, .spacingL)
            }
            .offset(y: hasAppeared ? 0 : 20)
            .opacity(hasAppeared ? 1.0 : 0)

            // Action buttons
            if actionTitle != nil || secondaryActionTitle != nil {
                VStack(spacing: .spacingM) {
                    if let actionTitle = actionTitle, let action = action {
                        PrimaryButton(title: actionTitle, action: action)
                            .padding(.horizontal, .spacing2XL)
                    }

                    if let secondaryTitle = secondaryActionTitle, let secondaryAction = secondaryAction {
                        Button(action: {
                            Haptics.selection()
                            secondaryAction()
                        }) {
                            Text(secondaryTitle)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.brandPrimary)
                        }
                    }
                }
                .padding(.top, .spacingS)
                .offset(y: hasAppeared ? 0 : 20)
                .opacity(hasAppeared ? 1.0 : 0)
            }
        }
        .padding(.spacing3XL)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                hasAppeared = true
            }
        }
    }
}

// MARK: - Compact Empty State (for inline use)
struct CompactEmptyState: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: .spacingM) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(LinearGradient.brand.opacity(0.6))

            VStack(spacing: .spacingS) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.adaptiveTextPrimary())

                Text(message)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.spacingXL)
        .background(
            RoundedRectangle(cornerRadius: .radiusMedium)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview("Full Empty State") {
    EmptyStateView(
        icon: "briefcase",
        title: "No Opportunities Yet",
        message: "Check back soon for new opportunities that match your profile.",
        actionTitle: "Browse Opportunities",
        action: {},
        secondaryActionTitle: "Learn More",
        secondaryAction: {}
    )
}

#Preview("Minimal Empty State") {
    EmptyStateView(
        icon: "message",
        title: "No Messages",
        message: "Start a conversation to connect with brands and creators."
    )
}

#Preview("Compact Empty State") {
    CompactEmptyState(
        icon: "photo.on.rectangle.angled",
        title: "No Portfolio Items",
        message: "Add your best work to impress collaborators"
    )
    .padding()
}

