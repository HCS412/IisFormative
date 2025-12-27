//
//  Campaign.swift
//  FormativeiOS
//
//  Campaign Models
//

import Foundation

struct Campaign: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let brandId: String
    let brandName: String?
    let status: CampaignStatus
    let budget: Double?
    let milestones: [Milestone]?
    let deliverables: [Deliverable]?
    let escrowEnabled: Bool
    let escrowStatus: EscrowStatus?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case description
        case brandId
        case brandName
        case status
        case budget
        case milestones
        case deliverables
        case escrowEnabled
        case escrowStatus
        case createdAt
        case updatedAt
    }
}

enum CampaignStatus: String, Codable {
    case draft
    case active
    case completed
    case cancelled
}

struct Milestone: Codable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let dueDate: String?
    let budget: Double?
    let isCompleted: Bool
    let completedAt: String?
}

struct Deliverable: Codable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let type: DeliverableType
    let isCompleted: Bool
    let completedAt: String?
    let attachments: [String]?
}

enum DeliverableType: String, Codable {
    case post
    case story
    case reel
    case video
    case photo
    case other
}

enum EscrowStatus: String, Codable {
    case pending
    case funded
    case released
    case refunded
}

