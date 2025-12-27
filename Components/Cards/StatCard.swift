//
//  StatCard.swift
//  FormativeiOS
//
//  Stat Card Component for Dashboard
//

import SwiftUI

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    var gradient: LinearGradient = .brand
    var showAnimation: Bool = true
    
    @State private var animatedValue: Double = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(gradient)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title1)
                    .fontWeight(.bold)
                    .foregroundColor(.adaptiveTextPrimary())
                    .contentTransition(.numericText())
                
                Text(label)
                    .font(.subhead)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(.spacingL)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.adaptiveSurface())
        .cornerRadius(.radiusMedium)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        .onAppear {
            if showAnimation {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animatedValue = 1.0
                }
            }
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        StatCard(
            icon: "briefcase.fill",
            value: "24",
            label: "Applications"
        )
        StatCard(
            icon: "dollarsign.circle.fill",
            value: "$12.5k",
            label: "Earnings",
            gradient: LinearGradient(
                colors: [Color.success, Color.success.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    .padding()
}

