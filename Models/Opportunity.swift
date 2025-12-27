//
//  Opportunity.swift
//  FormativeiOS
//
//  Created on [Date]
//

import Foundation

struct Opportunity: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let company: String?
    let location: String?
    let type: String? // e.g., "full-time", "part-time", "contract"
    let compensation: String?
    let requirements: [String]?
    let deadline: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case description
        case company
        case location
        case type
        case compensation
        case requirements
        case deadline
        case createdAt
        case updatedAt
    }
}

struct OpportunitiesResponse: Codable {
    let opportunities: [Opportunity]
    let total: Int?
    let page: Int?
    let limit: Int?
}

struct ApplyRequest: Codable {
    let message: String?
    let resume: String? // URL or base64
}

