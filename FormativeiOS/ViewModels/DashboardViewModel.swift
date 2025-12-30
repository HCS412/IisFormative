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
    @Published var socialStats: AggregatedSocialStats = AggregatedSocialStats()
    @Published var socialAccounts: [SocialAccount] = []
    @Published var recentActivity: [ActivityItem] = []
    @Published var notifications: [BackendNotification] = []
    @Published var unreadCount: Int = 0
    @Published var pendingInvitations: [TeamInvitation] = []
    @Published var recentOpportunities: [Opportunity] = []
    @Published var recommendedOpportunities: [RecommendedOpportunity] = []
    @Published var upcomingDeadlines: [CalendarDeadline] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient = APIClient.shared
    private var currentUser: User?

    func loadDashboard(user: User? = nil) async {
        isLoading = true
        errorMessage = nil
        currentUser = user

        // Load social accounts, notifications, stats, and opportunities in parallel
        async let socialTask = loadSocialAccounts()
        async let notificationsTask = loadNotifications()
        async let statsTask = loadStats()
        async let opportunitiesTask = loadOpportunitiesAndRecommendations()

        _ = await (socialTask, notificationsTask, statsTask, opportunitiesTask)

        isLoading = false
    }

    // MARK: - Load Social Accounts (Real Stats)
    private func loadSocialAccounts() async {
        do {
            let response: SocialAccountsResponse = try await apiClient.request(
                endpoint: "/user/social-accounts"
            )
            socialAccounts = response.accounts
            calculateAggregatedSocialStats()
        } catch {
            // No social accounts connected - leave empty
            socialAccounts = []
            socialStats = AggregatedSocialStats()
        }
    }

    private func calculateAggregatedSocialStats() {
        var aggregated = AggregatedSocialStats()

        for account in socialAccounts {
            if let accountStats = account.stats {
                aggregated.totalFollowers += accountStats.totalFollowers
                if let engagement = accountStats.engagementRate {
                    aggregated.totalEngagementRate += engagement
                }
            }
            aggregated.platformCount += 1
        }

        aggregated.accounts = socialAccounts
        socialStats = aggregated
    }

    // MARK: - Load Stats (Brand stats or user stats)
    private func loadStats() async {
        // For brands, try brand-specific stats endpoint
        if currentUser?.userType == "brand" {
            do {
                let response: BrandStatsResponse = try await apiClient.request(
                    endpoint: "/brand/stats"
                )
                stats = DashboardStats(
                    applications: response.totalApplications ?? 0,
                    earnings: 0.0,
                    profileViews: response.profileViews ?? 0,
                    campaigns: response.activeOpportunities ?? 0
                )
                return
            } catch {
                // Fall through to generic stats
            }
        }

        // For influencers/freelancers, try user stats
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
            // No stats available - stats will be nil
            stats = nil
        }
    }

    // MARK: - Load Notifications (Activity Feed)
    private func loadNotifications() async {
        do {
            let response: NotificationsResponse = try await apiClient.request(
                endpoint: "/notifications"
            )
            notifications = response.notifications
            unreadCount = response.unreadCount ?? 0

            // Convert to activity items for the UI
            recentActivity = response.notifications.prefix(10).map { notification in
                ActivityItem(
                    id: String(notification.id),
                    type: ActivityType.from(string: notification.type),
                    title: notification.title,
                    message: notification.message,
                    timestamp: ISO8601DateFormatter().date(from: notification.createdAt ?? "") ?? Date(),
                    relatedId: notification.relatedId != nil ? String(notification.relatedId!) : nil
                )
            }
        } catch {
            // No notifications - leave empty
            notifications = []
            recentActivity = []
            unreadCount = 0
        }
    }

    // MARK: - Mark Notification as Read
    func markNotificationRead(_ notificationId: Int) async {
        do {
            try await apiClient.request(
                endpoint: "/notifications/\(notificationId)/read",
                method: "PUT"
            )
            // Update local state
            if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
                // Notifications array is immutable, so reload
                await loadNotifications()
            }
        } catch {
            // Silent fail - not critical
        }
    }

    // MARK: - Mark All Notifications as Read
    func markAllNotificationsRead() async {
        do {
            let _: MarkAllReadResponse = try await apiClient.request(
                endpoint: "/notifications/read-all",
                method: "PUT"
            )
            // Reload notifications
            await loadNotifications()
        } catch {
            // Silent fail - not critical
        }
    }

    private func loadOpportunitiesAndRecommendations() async {
        do {
            let response: OpportunitiesResponse = try await apiClient.request(
                endpoint: "/opportunities"
            )

            // Store recent opportunities
            recentOpportunities = Array(response.opportunities.prefix(3))

            // Generate recommendations using scoring algorithm
            let engine = RecommendationEngine(user: currentUser)
            let scored = response.opportunities.map { opportunity in
                let score = engine.score(opportunity: opportunity)
                return RecommendedOpportunity(opportunity: opportunity, score: score)
            }

            // Sort by score and take top recommendations
            recommendedOpportunities = scored
                .sorted { $0.score > $1.score }
                .prefix(6)
                .map { $0 }

            // Extract deadlines from opportunities
            extractDeadlines(from: response.opportunities)

        } catch {
            recentOpportunities = []
            recommendedOpportunities = []
            upcomingDeadlines = []
        }
    }

    private func extractDeadlines(from opportunities: [Opportunity]) {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let now = Date()
        var deadlines: [CalendarDeadline] = []

        for opportunity in opportunities {
            guard let deadlineString = opportunity.deadline,
                  let date = formatter.date(from: deadlineString),
                  date > now else {
                continue
            }

            deadlines.append(CalendarDeadline(
                id: opportunity.id,
                title: opportunity.title,
                date: date,
                type: .opportunityDeadline,
                opportunityId: opportunity.id
            ))
        }

        // Sort by date and take next 5
        upcomingDeadlines = deadlines
            .sorted { $0.date < $1.date }
            .prefix(5)
            .map { $0 }
    }

    func refresh() async {
        await loadDashboard(user: currentUser)
    }

    // MARK: - Invitation Actions
    func acceptInvitation(_ invitation: TeamInvitation) async -> Bool {
        do {
            // Backend uses /teams/:id/respond with { response: 'accepted' }
            let request = TeamInvitationResponse(response: "accepted")
            let body = try JSONEncoder().encode(request)
            let _: EmptyResponse = try await apiClient.request(
                endpoint: "/teams/\(invitation.teamId)/respond",
                method: "PUT",
                body: body
            )
            // Remove from pending list
            pendingInvitations.removeAll { $0.id == invitation.id }
            return true
        } catch {
            errorMessage = "Failed to accept invitation: \(error.localizedDescription)"
            return false
        }
    }

    func declineInvitation(_ invitation: TeamInvitation) async -> Bool {
        do {
            // Backend uses /teams/:id/respond with { response: 'declined' }
            let request = TeamInvitationResponse(response: "declined")
            let body = try JSONEncoder().encode(request)
            let _: EmptyResponse = try await apiClient.request(
                endpoint: "/teams/\(invitation.teamId)/respond",
                method: "PUT",
                body: body
            )
            // Remove from pending list
            pendingInvitations.removeAll { $0.id == invitation.id }
            return true
        } catch {
            errorMessage = "Failed to decline invitation: \(error.localizedDescription)"
            return false
        }
    }
}

// MARK: - Team Invitation Response
struct TeamInvitationResponse: Codable {
    let response: String  // "accepted" or "declined"
}

// MARK: - Empty Response for void endpoints
struct EmptyResponse: Codable {
    let success: Bool?
    let message: String?
}

// MARK: - Calendar Deadline Model
struct CalendarDeadline: Identifiable {
    let id: Int
    let title: String
    let date: Date
    let type: DeadlineType
    let opportunityId: Int?

    enum DeadlineType {
        case opportunityDeadline
        case applicationDeadline
        case campaignMilestone
        case meeting

        var icon: String {
            switch self {
            case .opportunityDeadline: return "briefcase.fill"
            case .applicationDeadline: return "doc.fill"
            case .campaignMilestone: return "flag.fill"
            case .meeting: return "video.fill"
            }
        }

        var color: Color {
            switch self {
            case .opportunityDeadline: return .brandPrimary
            case .applicationDeadline: return .warning
            case .campaignMilestone: return .success
            case .meeting: return .brandSecondary
            }
        }
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

// Brand-specific stats response
struct BrandStatsResponse: Codable {
    let success: Bool?
    let activeOpportunities: Int?
    let totalApplications: Int?
    let profileViews: Int?
    let totalHires: Int?
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
