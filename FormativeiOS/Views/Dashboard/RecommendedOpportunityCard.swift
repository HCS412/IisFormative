//
//  RecommendedOpportunityCard.swift
//  FormativeiOS
//
//  Ice Cube Style Card for Recommended Opportunities
//

import SwiftUI

struct RecommendedOpportunityCard: View {
    let opportunity: Opportunity
    let onTap: () -> Void

    @State private var isPressed = false

    private var typeColor: Color {
        switch opportunity.type?.lowercased() {
        case "influencer": return .brandPrimary
        case "content": return .brandSecondary
        case "ambassador": return .success
        case "partnership": return .warning
        default: return .brandPrimary
        }
    }

    var body: some View {
        Button(action: {
            Haptics.impact(.light)
            onTap()
        }) {
            VStack(alignment: .leading, spacing: .spacingM) {
                // Header with type badge
                HStack {
                    // Type badge
                    Text(opportunity.type?.uppercased() ?? "OPPORTUNITY")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.5)
                        .foregroundColor(typeColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(typeColor.opacity(0.15))
                        .cornerRadius(4)

                    Spacer()

                    // Match score indicator
                    if let score = opportunity.matchScore, score > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 10))
                            Text("\(Int(score))%")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundColor(.brandPrimary)
                    }
                }

                // Company/Brand
                HStack(spacing: 6) {
                    Circle()
                        .fill(LinearGradient.brand)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Text(String(opportunity.companyName.prefix(1)).uppercased())
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        )

                    Text(opportunity.companyName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                }

                // Title
                Text(opportunity.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.adaptiveTextPrimary())
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)

                // Footer with budget and deadline
                HStack {
                    // Budget
                    Label(opportunity.budget, systemImage: "dollarsign.circle.fill")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.success)

                    Spacer()

                    // Deadline indicator
                    if opportunity.deadline != nil {
                        HStack(spacing: 2) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 9))
                            Text(formatDeadline(opportunity.deadline))
                                .font(.caption2)
                        }
                        .foregroundColor(.textSecondary)
                    }
                }
            }
            .padding(.spacingM)
            .frame(width: 180, height: 180)
            .background(
                ZStack {
                    // Base frosted glass
                    RoundedRectangle(cornerRadius: .radiusMedium)
                        .fill(.ultraThinMaterial)

                    // Subtle gradient overlay
                    RoundedRectangle(cornerRadius: .radiusMedium)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.02)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                // Border gradient
                RoundedRectangle(cornerRadius: .radiusMedium)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            // Layered shadows for depth (ice cube effect)
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            .shadow(color: .black.opacity(0.04), radius: 16, y: 8)
            .shadow(color: typeColor.opacity(0.1), radius: 20, y: 10)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.springSnappy, value: isPressed)
        }
        .buttonStyle(PressableCardButtonStyle(isPressed: $isPressed))
    }
}

// MARK: - Pressable Button Style (doesn't block scroll)
struct PressableCardButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}

// MARK: - Helper Extension
extension RecommendedOpportunityCard {
    func formatDeadline(_ deadline: String?) -> String {
        guard let deadline = deadline else { return "" }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = formatter.date(from: deadline) {
            let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
            if days < 0 {
                return "Ended"
            } else if days == 0 {
                return "Today"
            } else if days == 1 {
                return "1 day"
            } else if days < 7 {
                return "\(days) days"
            } else {
                let weeks = days / 7
                return "\(weeks)w left"
            }
        }
        return ""
    }
}

// MARK: - Match Score Extension
extension Opportunity {
    var matchScore: Double? {
        // This will be calculated by the recommendation algorithm
        // Stored temporarily for display
        nil
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color.brandPrimary.opacity(0.1), Color.brandSecondary.opacity(0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        HStack(spacing: 12) {
            RecommendedOpportunityCard(
                opportunity: Opportunity(
                    id: 1,
                    title: "Summer Brand Ambassador Campaign",
                    description: "Looking for creators",
                    type: "influencer",
                    industry: "Fashion",
                    budgetRange: "$500-$2000",
                    budgetMin: 500,
                    budgetMax: 2000,
                    createdBy: 1,
                    createdByName: "Nike",
                    status: "active",
                    requirements: nil,
                    platforms: nil,
                    deadline: "2025-01-15T00:00:00.000Z",
                    location: nil,
                    isRemote: true,
                    createdAt: nil,
                    updatedAt: nil
                ),
                onTap: {}
            )

            RecommendedOpportunityCard(
                opportunity: Opportunity(
                    id: 2,
                    title: "Content Creator for Tech Reviews",
                    description: "Create engaging content",
                    type: "content",
                    industry: "Technology",
                    budgetRange: "$1000-$3000",
                    budgetMin: 1000,
                    budgetMax: 3000,
                    createdBy: 2,
                    createdByName: "Apple",
                    status: "active",
                    requirements: nil,
                    platforms: nil,
                    deadline: "2025-01-10T00:00:00.000Z",
                    location: nil,
                    isRemote: true,
                    createdAt: nil,
                    updatedAt: nil
                ),
                onTap: {}
            )
        }
        .padding()
    }
}
