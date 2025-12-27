//
//  Notification.swift
//  FormativeiOS
//
//  Notification Models
//

import Foundation
import SwiftUI

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
}

enum NotificationType: String, Codable {
    case applicationAccepted = "application_accepted"
    case applicationRejected = "application_rejected"
    case newMessage = "new_message"
    case teamInvitation = "team_invitation"
    case campaignUpdate = "campaign_update"
    case paymentReceived = "payment_received"
    
    var icon: String {
        switch self {
        case .applicationAccepted: return "checkmark.circle.fill"
        case .applicationRejected: return "xmark.circle.fill"
        case .newMessage: return "message.fill"
        case .teamInvitation: return "person.2.fill"
        case .campaignUpdate: return "bell.fill"
        case .paymentReceived: return "dollarsign.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .applicationAccepted: return .success
        case .applicationRejected: return .error
        case .newMessage: return .brandPrimary
        case .teamInvitation: return .brandSecondary
        case .campaignUpdate: return .warning
        case .paymentReceived: return .success
        }
    }
}

