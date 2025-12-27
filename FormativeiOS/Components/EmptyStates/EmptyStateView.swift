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
    
    var body: some View {
        VStack(spacing: .spacingXL) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(LinearGradient.brand)
                .symbolEffect(.bounce, value: actionTitle)
            
            VStack(spacing: .spacingS) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.adaptiveTextPrimary())
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, .spacing3XL)
            }
            
            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(title: actionTitle, action: action)
                    .padding(.horizontal, .spacing3XL)
                    .padding(.top, .spacingM)
            }
        }
        .padding(.spacing5XL)
    }
}

#Preview {
    EmptyStateView(
        icon: "briefcase",
        title: "No Opportunities Yet",
        message: "Check back soon for new opportunities that match your profile.",
        actionTitle: "Refresh",
        action: {}
    )
}

