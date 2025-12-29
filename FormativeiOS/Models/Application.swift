//
//  Application.swift
//  FormativeiOS
//
//  Application models for job/opportunity applications
//

import Foundation

// MARK: - Application Model
struct Application: Codable, Identifiable {
    let id: Int
    let opportunityId: Int
    let userId: Int
    let message: String?
    let coverLetter: String?
    let proposedRate: String?
    let portfolioLinks: [String]?
    let status: String?
    let createdAt: String?
    let updatedAt: String?

    // Related opportunity data (may be included in response)
    let opportunity: Opportunity?

    // Computed properties
    var statusDisplay: String {
        status?.capitalized ?? "Pending"
    }

    var isActive: Bool {
        status == "pending" || status == "reviewing"
    }
}

// MARK: - Application Status
enum ApplicationStatus: String, CaseIterable {
    case pending = "pending"
    case reviewing = "reviewing"
    case accepted = "accepted"
    case rejected = "rejected"
    case withdrawn = "withdrawn"

    var displayName: String {
        rawValue.capitalized
    }

    var color: String {
        switch self {
        case .pending: return "warning"
        case .reviewing: return "brandPrimary"
        case .accepted: return "success"
        case .rejected: return "error"
        case .withdrawn: return "textSecondary"
        }
    }
}

// MARK: - API Responses
struct ApplicationsResponse: Codable {
    let success: Bool?
    let applications: [Application]
    let total: Int?
}

struct ApplicationResponse: Codable {
    let success: Bool?
    let application: Application?
    let message: String?
}

// MARK: - Submit Application Request
struct SubmitApplicationRequest: Codable {
    let message: String
    let coverLetter: String?
    let proposedRate: String?
    let portfolioLinks: [String]?

    init(message: String, coverLetter: String? = nil, proposedRate: String? = nil, portfolioLinks: [String]? = nil) {
        self.message = message
        self.coverLetter = coverLetter
        self.proposedRate = proposedRate?.isEmpty == true ? nil : proposedRate
        self.portfolioLinks = portfolioLinks?.isEmpty == true ? nil : portfolioLinks
    }
}
