//
//  DashboardViewModel.swift
//  FormativeiOS
//
//  Dashboard View Model - Connects to Railway backend
//

import Foundation
import SwiftUI
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var stats: DashboardStats?
    @Published var recentActivity: [ActivityItem] = []
    @Published var pendingInvitations: [TeamInvitation] = []
    @Published var recentOpportunities: [Opportunity] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient = APIClient.shared

    func loadDashboard() async {
        isLoading = true
        errorMessage = nil

        // Load stats, activity, and opportunities in parallel
        async let statsTask = loadStats()
        async let activityTask = loadRecentActivity()
        async let opportunitiesTask = loadRecentOpportunities()

        _ = await (statsTask, activityTask, opportunitiesTask)

        isLoading = false
    }

    private func loadStats() async {
        // Try to fetch user stats from the API
        do {
            let response: DashboardStatsResponse = try await apiClient.request(
                endpoint: "/user/stats"
            )
            stats = DashboardStats(
                applications: response.applications ?? 0,
                earnings: response.earnings ?? 0.0,
                profileViews: response.profileViews ?? 0,
                campaigns: response.campaigns ?? 0
            )
        } catch {
            // If endpoint doesn't exist, show placeholder stats
            // These would normally come from a real API
            stats = DashboardStats(
                applications: 0,
                earnings: 0.0,
                profileViews: 0,
                campaigns: 0
            )
        }
    }

    private func loadRecentActivity() async {
        do {
            let response: ActivityResponse = try await apiClient.request(
                endpoint: "/user/activity"
            )
            recentActivity = response.activities.map { item in
                ActivityItem(
                    id: String(item.id),
                    type: ActivityType.from(string: item.type),
                    title: item.title,
                    message: item.message,
                    timestamp: ISO8601DateFormatter().date(from: item.createdAt ?? "") ?? Date(),
                    relatedId: item.relatedId != nil ? String(item.relatedId!) : nil
                )
            }
        } catch {
            // If no activity endpoint, show empty state
            recentActivity = []
        }
    }

    private func loadRecentOpportunities() async {
        do {
            let response: OpportunitiesResponse = try await apiClient.request(
                endpoint: "/opportunities"
            )
            // Show first 3 opportunities on dashboard
            recentOpportunities = Array(response.opportunities.prefix(3))
        } catch {
            recentOpportunities = []
        }
    }

    func refresh() async {
        await loadDashboard()
    }
}

// MARK: - API Response Models
struct DashboardStatsResponse: Codable {
    let success: Bool?
    let applications: Int?
    let earnings: Double?
    let profileViews: Int?
    let campaigns: Int?
}

struct ActivityResponse: Codable {
    let success: Bool?
    let activities: [ActivityAPIItem]
}

struct ActivityAPIItem: Codable {
    let id: Int
    let type: String
    let title: String
    let message: String
    let relatedId: Int?
    let createdAt: String?
}

// MARK: - Data Models
struct DashboardStats {
    let applications: Int
    let earnings: Double
    let profileViews: Int
    let campaigns: Int
}

struct ActivityItem: Identifiable {
    let id: String
    let type: ActivityType
    let title: String
    let message: String
    let timestamp: Date
    let relatedId: String?
}

enum ActivityType {
    case applicationAccepted
    case applicationRejected
    case newMessage
    case campaignUpdate
    case paymentReceived
    case teamInvitation
    case opportunityPosted
    case general

    static func from(string: String) -> ActivityType {
        switch string.lowercased() {
        case "application_accepted": return .applicationAccepted
        case "application_rejected": return .applicationRejected
        case "new_message", "message": return .newMessage
        case "campaign_update": return .campaignUpdate
        case "payment_received", "payment": return .paymentReceived
        case "team_invitation", "invitation": return .teamInvitation
        case "opportunity_posted", "opportunity": return .opportunityPosted
        default: return .general
        }
    }

    var icon: String {
        switch self {
        case .applicationAccepted: return "checkmark.circle.fill"
        case .applicationRejected: return "xmark.circle.fill"
        case .newMessage: return "message.fill"
        case .campaignUpdate: return "bell.fill"
        case .paymentReceived: return "dollarsign.circle.fill"
        case .teamInvitation: return "person.2.fill"
        case .opportunityPosted: return "briefcase.fill"
        case .general: return "bell.fill"
        }
    }

    var color: Color {
        switch self {
        case .applicationAccepted: return .success
        case .applicationRejected: return .error
        case .newMessage: return .brandPrimary
        case .campaignUpdate: return .warning
        case .paymentReceived: return .success
        case .teamInvitation: return .brandSecondary
        case .opportunityPosted: return .brandPrimary
        case .general: return .textSecondary
        }
    }
}

// TeamInvitation is defined in Models/Team.swift
