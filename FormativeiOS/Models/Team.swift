//
//  Team.swift
//  FormativeiOS
//
//  Team Models
//

import Foundation

struct Team: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let type: TeamType
    let logo: String?
    let members: [TeamMember]
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case description
        case type
        case logo
        case members
        case createdAt
    }
}

enum TeamType: String, Codable {
    case brand
    case agency
    case creatorCollective = "creator_collective"
}

struct TeamMember: Codable, Identifiable {
    let id: String
    let userId: String
    let role: TeamRole
    let user: User?
    let joinedAt: String
}

enum TeamRole: String, Codable {
    case owner
    case admin
    case member
}

struct TeamInvitation: Codable, Identifiable {
    let id: String
    let teamId: String
    let teamName: String
    let inviterId: String
    let inviterName: String
    let status: InvitationStatus
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case teamId
        case teamName
        case inviterId
        case inviterName
        case status
        case createdAt
    }
}

enum InvitationStatus: String, Codable {
    case pending
    case accepted
    case declined
}

