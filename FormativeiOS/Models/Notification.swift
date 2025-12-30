//
//  Notification.swift
//  FormativeiOS
//
//  Notification Models - Matches Railway backend /notifications endpoint
//

import Foundation
import SwiftUI

// MARK: - Backend Notification Model
struct BackendNotification: Codable, Identifiable {
    let id: Int
    let userId: Int
    let type: String
    let title: String
    let message: String
    let relatedId: Int?
    let relatedType: String?
    let isRead: Bool?
    let createdAt: String?
    let updatedAt: String?

    var notificationType: NotificationType {
        NotificationType(rawValue: type) ?? .general
    }
}

// MARK: - Notifications Response
struct NotificationsResponse: Codable {
    let success: Bool?
    let notifications: [BackendNotification]
    let unreadCount: Int?
}

// MARK: - Mark Read Request
struct MarkNotificationReadRequest: Codable {
    let notificationId: Int
}

struct MarkAllReadResponse: Codable {
    let success: Bool?
    let message: String?
}

// MARK: - Legacy App Notification (for backwards compatibility)
struct AppNotification: Codable, Identifiable {
    let id: String
    let type: NotificationType
    let title: String
    let message: String
    let imageUrl: String?
    let relatedId: String?
    let isRead: Bool
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type
        case title
        case message
        case imageUrl
        case relatedId
        case isRead
        case createdAt
    }

    // Initialize from backend notification
    init(from backend: BackendNotification) {
        self.id = String(backend.id)
        self.type = backend.notificationType
        self.title = backend.title
        self.message = backend.message
        self.imageUrl = nil
        self.relatedId = backend.relatedId != nil ? String(backend.relatedId!) : nil
        self.isRead = backend.isRead ?? false
        self.createdAt = backend.createdAt ?? ""
    }
}

enum NotificationType: String, Codable {
    case applicationAccepted = "application_accepted"
    case applicationRejected = "application_rejected"
    case applicationSubmitted = "application_submitted"
    case newMessage = "new_message"
    case message = "message"
    case teamInvitation = "team_invitation"
    case invitation = "invitation"
    case campaignUpdate = "campaign_update"
    case paymentReceived = "payment_received"
    case payment = "payment"
    case opportunityPosted = "opportunity_posted"
    case opportunity = "opportunity"
    case general = "general"

    var icon: String {
        switch self {
        case .applicationAccepted: return "checkmark.circle.fill"
        case .applicationRejected: return "xmark.circle.fill"
        case .applicationSubmitted: return "doc.fill"
        case .newMessage, .message: return "message.fill"
        case .teamInvitation, .invitation: return "person.2.fill"
        case .campaignUpdate: return "bell.fill"
        case .paymentReceived, .payment: return "dollarsign.circle.fill"
        case .opportunityPosted, .opportunity: return "briefcase.fill"
        case .general: return "bell.fill"
        }
    }

    var color: Color {
        switch self {
        case .applicationAccepted: return .success
        case .applicationRejected: return .error
        case .applicationSubmitted: return .brandPrimary
        case .newMessage, .message: return .brandPrimary
        case .teamInvitation, .invitation: return .brandSecondary
        case .campaignUpdate: return .warning
        case .paymentReceived, .payment: return .success
        case .opportunityPosted, .opportunity: return .brandPrimary
        case .general: return .textSecondary
        }
    }
}

