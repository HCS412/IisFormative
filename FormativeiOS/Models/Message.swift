//
//  Message.swift
//  FormativeiOS
//
//  Message Models - Matching PostgreSQL backend
//

import Foundation

struct Conversation: Codable, Identifiable {
    let id: Int
    let participantId: Int?
    let participantName: String?
    let participantAvatar: String?
    let lastMessageContent: String?
    let lastMessageAt: String?
    let unreadCount: Int?
    let createdAt: String?
    let updatedAt: String?

    // Display helpers
    var displayName: String {
        participantName ?? "Unknown User"
    }

    var lastMessagePreview: String {
        lastMessageContent ?? "No messages yet"
    }
}

struct ConversationsResponse: Codable {
    let success: Bool?
    let conversations: [Conversation]
}

struct Message: Codable, Identifiable {
    let id: Int
    let conversationId: Int
    let senderId: Int
    let senderName: String?
    let content: String
    let type: String?
    let attachments: [MessageAttachment]?
    let readAt: String?
    let deliveredAt: String?
    let createdAt: String?

    var isFromCurrentUser: Bool {
        // This would be set based on current user ID
        false
    }
}

struct MessagesResponse: Codable {
    let success: Bool?
    let messages: [Message]
}

struct MessageAttachment: Codable, Identifiable {
    let id: Int
    let type: String
    let url: String
    let thumbnailUrl: String?
    let fileName: String?
    let fileSize: Int?
}

struct SendMessageRequest: Codable {
    let conversationId: Int?
    let recipientId: Int?
    let content: String
    let attachments: [String]?
}

struct SendMessageResponse: Codable {
    let success: Bool
    let message: Message?
}
