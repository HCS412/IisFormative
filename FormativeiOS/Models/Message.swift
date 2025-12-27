//
//  Message.swift
//  FormativeiOS
//
//  Message Models
//

import Foundation

struct Conversation: Codable, Identifiable {
    let id: String
    let participant: User
    let lastMessage: Message?
    let unreadCount: Int
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case participant
        case lastMessage
        case unreadCount
        case updatedAt
    }
}

struct Message: Codable, Identifiable {
    let id: String
    let conversationId: String
    let senderId: String
    let content: String
    let type: MessageType
    let attachments: [MessageAttachment]?
    let readAt: String?
    let deliveredAt: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case conversationId
        case senderId
        case content
        case type
        case attachments
        case readAt
        case deliveredAt
        case createdAt
    }
}

enum MessageType: String, Codable {
    case text
    case image
    case file
    case system
}

struct MessageAttachment: Codable {
    let id: String
    let type: String
    let url: String
    let thumbnailUrl: String?
    let fileName: String?
    let fileSize: Int?
}

struct SendMessageRequest: Codable {
    let conversationId: String?
    let recipientId: String?
    let content: String
    let attachments: [String]?
}

