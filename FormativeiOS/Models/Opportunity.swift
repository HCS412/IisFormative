//
//  Opportunity.swift
//  FormativeiOS
//
//  Opportunity models matching backend API
//

import Foundation

struct Opportunity: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let description: String
    let type: String?
    let industry: String?
    let budgetRange: String?
    let budgetMin: Double?
    let budgetMax: Double?
    let createdBy: Int?
    let createdByName: String?
    let status: String?
    let requirements: [String]?
    let platforms: [String]?
    let deadline: String?
    let location: String?
    let isRemote: Bool?
    let createdAt: String?
    let updatedAt: String?

    // Computed property for display
    var budget: String {
        if let range = budgetRange, !range.isEmpty {
            return range
        }
        if let min = budgetMin, let max = budgetMax {
            return "$\(Int(min)) - $\(Int(max))"
        }
        return "Budget TBD"
    }

    var companyName: String {
        createdByName ?? "Anonymous"
    }

    // Hashable conformance (based on unique id)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Opportunity, rhs: Opportunity) -> Bool {
        lhs.id == rhs.id
    }
}

struct OpportunitiesResponse: Codable {
    let success: Bool?
    let opportunities: [Opportunity]
    let total: Int?
    let page: Int?
    let limit: Int?
}

struct OpportunityDetailResponse: Codable {
    let success: Bool?
    let opportunity: Opportunity
}

struct ApplyRequest: Codable {
    let opportunityId: Int
    let message: String?
    let coverLetter: String?
}

struct ApplyResponse: Codable {
    let success: Bool
    let message: String?
    let applicationId: Int?
}
