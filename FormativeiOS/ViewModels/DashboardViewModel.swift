//
//  DashboardViewModel.swift
//  FormativeiOS
//
//  Dashboard View Model
//

import Foundation
import SwiftUI
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var stats: DashboardStats?
    @Published var recentActivity: [ActivityItem] = []
    @Published var pendingInvitations: [TeamInvitation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient.shared
    
    func loadDashboard() async {
        isLoading = true
        errorMessage = nil
        
        // Load stats, activity, and invitations in parallel
        async let statsTask = loadStats()
        async let activityTask = loadRecentActivity()
        async let invitationsTask = loadPendingInvitations()
        
        _ = await (statsTask, activityTask, invitationsTask)
        
        isLoading = false
    }
    
    private func loadStats() async {
        do {
            // This would call your actual API endpoint
            // For now, using mock data structure
            stats = DashboardStats(
                applications: 24,
                earnings: 12500.0,
                profileViews: 156,
                campaigns: 3
            )
        } catch {
            errorMessage = "Failed to load stats: \(error.localizedDescription)"
        }
    }
    
    private func loadRecentActivity() async {
        do {
            // Mock activity data - replace with actual API call
            recentActivity = [
                ActivityItem(
                    id: "1",
                    type: .applicationAccepted,
                    title: "Application Accepted",
                    message: "Your application for 'Social Media Manager' was accepted",
                    timestamp: Date().addingTimeInterval(-3600),
                    relatedId: "opp-1"
                ),
                ActivityItem(
                    id: "2",
                    type: .newMessage,
                    title: "New Message",
                    message: "You have a new message from Brand Co.",
                    timestamp: Date().addingTimeInterval(-7200),
                    relatedId: "msg-1"
                ),
                ActivityItem(
                    id: "3",
                    type: .campaignUpdate,
                    title: "Campaign Milestone",
                    message: "Milestone 1 completed for 'Summer Campaign'",
                    timestamp: Date().addingTimeInterval(-86400),
                    relatedId: "camp-1"
                )
            ]
        } catch {
            errorMessage = "Failed to load activity: \(error.localizedDescription)"
        }
    }
    
    private func loadPendingInvitations() async {
        do {
            // Mock invitations - replace with actual API call
            pendingInvitations = []
        } catch {
            errorMessage = "Failed to load invitations: \(error.localizedDescription)"
        }
    }
    
    func refresh() async {
        await loadDashboard()
    }
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
    
    var icon: String {
        switch self {
        case .applicationAccepted: return "checkmark.circle.fill"
        case .applicationRejected: return "xmark.circle.fill"
        case .newMessage: return "message.fill"
        case .campaignUpdate: return "bell.fill"
        case .paymentReceived: return "dollarsign.circle.fill"
        case .teamInvitation: return "person.2.fill"
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
        }
    }
}

// TeamInvitation is defined in Models/Team.swift

