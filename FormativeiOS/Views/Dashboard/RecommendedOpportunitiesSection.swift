//
//  RecommendedOpportunitiesSection.swift
//  FormativeiOS
//
//  Carousel Section for Recommended Opportunities
//

import SwiftUI

struct RecommendedOpportunitiesSection: View {
    let opportunities: [RecommendedOpportunity]
    let onSeeAll: () -> Void
    let onSelect: (Opportunity) -> Void

    @State private var currentPage = 0

    var body: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            // Header
            HStack {
                HStack(spacing: .spacingS) {
                    Image(systemName: "sparkles")
                        .font(.subheadline)
                        .foregroundStyle(LinearGradient.brand)

                    Text("Recommended For You")
                        .font(.headline)
                        .foregroundColor(.adaptiveTextPrimary())
                }

                Spacer()

                Button(action: {
                    Haptics.selection()
                    onSeeAll()
                }) {
                    HStack(spacing: 4) {
                        Text("See All")
                            .font(.subheadline)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundColor(.brandPrimary)
                }
            }
            .padding(.horizontal, .spacingL)

            if opportunities.isEmpty {
                // Empty state
                emptyState
                    .padding(.horizontal, .spacingL)
            } else {
                // Carousel with explicit scroll gesture priority
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(opportunities) { item in
                            RecommendedOpportunityCard(
                                opportunity: item.opportunity,
                                onTap: { onSelect(item.opportunity) }
                            )
                        }

                        // Add trailing space for last card visibility
                        Spacer()
                            .frame(width: 1)
                    }
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
                    .padding(.vertical, 8)
                }
                .scrollBounceBehavior(.always)
                .frame(height: 200)

                // Page indicator dots
                if opportunities.count > 2 {
                    HStack(spacing: 6) {
                        ForEach(0..<min(opportunities.count, 5), id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.brandPrimary : Color.textSecondary.opacity(0.3))
                                .frame(width: 6, height: 6)
                                .animation(.springSmooth, value: currentPage)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, .spacingS)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: .spacingM) {
            Image(systemName: "sparkles")
                .font(.system(size: 32))
                .foregroundStyle(LinearGradient.brand.opacity(0.5))

            Text("No recommendations yet")
                .font(.subheadline)
                .foregroundColor(.textSecondary)

            Text("Complete your profile to get personalized opportunities")
                .font(.caption)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.spacingXL)
        .background(
            RoundedRectangle(cornerRadius: .radiusMedium)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Recommended Opportunity Wrapper
struct RecommendedOpportunity: Identifiable {
    let id: Int
    let opportunity: Opportunity
    let score: Double

    init(opportunity: Opportunity, score: Double) {
        self.id = opportunity.id
        self.opportunity = opportunity
        self.score = score
    }
}

// MARK: - Recommendation Algorithm
struct RecommendationEngine {
    let userType: String?
    let userBio: String?
    let userIndustries: [String]

    init(user: User?) {
        self.userType = user?.userType
        self.userBio = user?.profileData?.bio
        self.userIndustries = extractIndustries(from: user?.profileData?.bio)
    }

    func score(opportunity: Opportunity) -> Double {
        var totalScore: Double = 0

        // 1. User Type Match (+30 points)
        totalScore += scoreUserTypeMatch(opportunity: opportunity)

        // 2. Industry/Niche Match (+40 points)
        totalScore += scoreIndustryMatch(opportunity: opportunity)

        // 3. Budget Alignment (+30 points)
        totalScore += scoreBudgetAlignment(opportunity: opportunity)

        return min(totalScore, 100)
    }

    private func scoreUserTypeMatch(opportunity: Opportunity) -> Double {
        guard let userType = userType?.lowercased(),
              let oppType = opportunity.type?.lowercased() else {
            return 15 // Default partial score
        }

        let creatorTypes = ["influencer", "content", "ambassador", "ugc"]
        let brandTypes = ["partnership", "sponsorship", "collaboration"]

        switch userType {
        case "influencer":
            if creatorTypes.contains(oppType) { return 30 }
            return 10
        case "brand":
            if brandTypes.contains(oppType) { return 30 }
            return 10
        case "freelancer":
            // Freelancers can work with various types
            return 25
        default:
            return 15
        }
    }

    private func scoreIndustryMatch(opportunity: Opportunity) -> Double {
        guard let oppIndustry = opportunity.industry?.lowercased() else {
            return 20 // Default score if no industry specified
        }

        // Check for direct match
        for industry in userIndustries {
            if oppIndustry.contains(industry.lowercased()) ||
               industry.lowercased().contains(oppIndustry) {
                return 40
            }
        }

        // Check for related industries
        let relatedIndustries: [String: [String]] = [
            "fashion": ["beauty", "lifestyle", "retail", "apparel"],
            "technology": ["tech", "software", "gaming", "electronics"],
            "food": ["beverage", "restaurant", "cooking", "nutrition"],
            "fitness": ["health", "wellness", "sports", "nutrition"],
            "travel": ["hospitality", "tourism", "adventure"],
            "beauty": ["fashion", "skincare", "cosmetics", "lifestyle"]
        ]

        for industry in userIndustries {
            if let related = relatedIndustries[industry.lowercased()],
               related.contains(where: { oppIndustry.contains($0) }) {
                return 25
            }
        }

        return 10 // No match
    }

    private func scoreBudgetAlignment(opportunity: Opportunity) -> Double {
        // For now, give higher scores to opportunities with clear budgets
        if opportunity.budgetMax != nil && opportunity.budgetMin != nil {
            let avgBudget = ((opportunity.budgetMin ?? 0) + (opportunity.budgetMax ?? 0)) / 2

            // Prefer mid-range budgets (most accessible)
            if avgBudget >= 500 && avgBudget <= 5000 {
                return 30
            } else if avgBudget > 5000 {
                return 20
            } else {
                return 15
            }
        }

        return 15 // Budget TBD
    }
}

// MARK: - Helper Functions
private func extractIndustries(from bio: String?) -> [String] {
    guard let bio = bio?.lowercased() else { return [] }

    let keywords = [
        "fashion", "beauty", "tech", "technology", "food", "travel",
        "fitness", "health", "lifestyle", "gaming", "music", "art",
        "photography", "design", "sports", "entertainment", "education",
        "finance", "business", "marketing", "wellness", "parenting"
    ]

    return keywords.filter { bio.contains($0) }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            RecommendedOpportunitiesSection(
                opportunities: [
                    RecommendedOpportunity(
                        opportunity: Opportunity(
                            id: 1,
                            title: "Summer Fashion Campaign",
                            description: "Looking for fashion influencers",
                            type: "influencer",
                            industry: "Fashion",
                            budgetRange: "$500-$2000",
                            budgetMin: 500,
                            budgetMax: 2000,
                            createdBy: 1,
                            createdByName: "Zara",
                            status: "active",
                            requirements: nil,
                            platforms: nil,
                            deadline: "2025-01-15T00:00:00.000Z",
                            location: nil,
                            isRemote: true,
                            createdAt: nil,
                            updatedAt: nil
                        ),
                        score: 92
                    ),
                    RecommendedOpportunity(
                        opportunity: Opportunity(
                            id: 2,
                            title: "Tech Review Creator",
                            description: "Create engaging tech content",
                            type: "content",
                            industry: "Technology",
                            budgetRange: "$1000-$3000",
                            budgetMin: 1000,
                            budgetMax: 3000,
                            createdBy: 2,
                            createdByName: "Samsung",
                            status: "active",
                            requirements: nil,
                            platforms: nil,
                            deadline: "2025-01-20T00:00:00.000Z",
                            location: nil,
                            isRemote: true,
                            createdAt: nil,
                            updatedAt: nil
                        ),
                        score: 85
                    ),
                    RecommendedOpportunity(
                        opportunity: Opportunity(
                            id: 3,
                            title: "Fitness Brand Ambassador",
                            description: "Long-term partnership",
                            type: "ambassador",
                            industry: "Fitness",
                            budgetRange: "$2000-$5000",
                            budgetMin: 2000,
                            budgetMax: 5000,
                            createdBy: 3,
                            createdByName: "Gymshark",
                            status: "active",
                            requirements: nil,
                            platforms: nil,
                            deadline: "2025-02-01T00:00:00.000Z",
                            location: nil,
                            isRemote: true,
                            createdAt: nil,
                            updatedAt: nil
                        ),
                        score: 78
                    )
                ],
                onSeeAll: {},
                onSelect: { _ in }
            )
        }
        .padding(.vertical)
    }
    .background(Color.adaptiveBackground())
}
