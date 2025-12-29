//
//  DashboardView.swift
//  FormativeiOS
//
//  Dashboard View with Stats and Activity
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var selectedTab: Int

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: .spacing2XL) {
                    // Personalized Greeting
                    greetingSection
                        .padding(.horizontal, .spacingL)
                        .padding(.top, .spacingL)
                    
                    // Stats Cards
                    if let stats = viewModel.stats {
                        statsSection(stats: stats)
                            .padding(.horizontal, .spacingL)
                    }
                    
                    // Quick Actions
                    quickActionsSection
                        .padding(.horizontal, .spacingL)
                    
                    // Recent Activity
                    if !viewModel.recentActivity.isEmpty {
                        activitySection
                            .padding(.horizontal, .spacingL)
                    }
                    
                    // Pending Invitations
                    if !viewModel.pendingInvitations.isEmpty {
                        invitationsSection
                            .padding(.horizontal, .spacingL)
                    }
                }
                .padding(.bottom, .spacing5XL)
            }
            .background(Color.adaptiveBackground())
            .navigationTitle("Dashboard")
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadDashboard()
            }
        }
    }
    
    // MARK: - Greeting Section
    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: .spacingS) {
            Text(timeBasedGreeting)
                .font(.title1)
                .fontWeight(.bold)
                .foregroundColor(.adaptiveTextPrimary())
            
            if let user = authViewModel.currentUser {
                Text("Welcome back, \(user.name)!")
                    .font(.headline)
                    .foregroundColor(.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
    
    // MARK: - Stats Section
    private func statsSection(stats: DashboardStats) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: .spacingM) {
                StatCard(
                    icon: "briefcase.fill",
                    value: "\(stats.applications)",
                    label: "Applications",
                    gradient: LinearGradient.brand
                )
                .frame(width: 160)
                
                StatCard(
                    icon: "dollarsign.circle.fill",
                    value: formatCurrency(stats.earnings),
                    label: "Earnings",
                    gradient: LinearGradient(
                        colors: [Color.success, Color.success.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 160)
                
                StatCard(
                    icon: "eye.fill",
                    value: "\(stats.profileViews)",
                    label: "Profile Views",
                    gradient: LinearGradient(
                        colors: [Color.brandSecondary, Color.brandSecondary.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 160)
                
                StatCard(
                    icon: "megaphone.fill",
                    value: "\(stats.campaigns)",
                    label: "Campaigns",
                    gradient: LinearGradient(
                        colors: [Color.warning, Color.warning.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 160)
            }
            .padding(.horizontal, .spacingL)
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(.adaptiveTextPrimary())

            HStack(spacing: .spacingM) {
                QuickActionButton(
                    icon: "magnifyingglass",
                    title: "Find Opportunities",
                    color: .brandPrimary
                ) {
                    selectedTab = 1 // Navigate to Opportunities tab
                }

                QuickActionButton(
                    icon: "message.fill",
                    title: "Messages",
                    color: .brandSecondary
                ) {
                    selectedTab = 2 // Navigate to Messages tab
                }

                QuickActionButton(
                    icon: "person.fill",
                    title: "Profile",
                    color: .success
                ) {
                    selectedTab = 3 // Navigate to Profile tab
                }
            }
        }
    }
    
    // MARK: - Activity Section
    private var activitySection: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Recent Activity")
                .font(.headline)
                .foregroundColor(.adaptiveTextPrimary())
            
            GlassCard {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.recentActivity.enumerated()), id: \.element.id) { index, activity in
                        ActivityRow(activity: activity)
                        
                        if index < viewModel.recentActivity.count - 1 {
                            Divider()
                                .padding(.vertical, .spacingM)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Invitations Section
    private var invitationsSection: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Pending Invitations")
                .font(.headline)
                .foregroundColor(.adaptiveTextPrimary())
            
            GlassCard {
                VStack(alignment: .leading, spacing: .spacingM) {
                    ForEach(viewModel.pendingInvitations) { invitation in
                        InvitationRow(invitation: invitation)
                    }
                }
            }
        }
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            Haptics.impact(.light)
            action()
        }) {
            VStack(spacing: .spacingS) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 50, height: 50)
                    .background(color.opacity(0.1))
                    .cornerRadius(.radiusMedium)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.adaptiveTextPrimary())
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.spacingM)
            .background(Color.adaptiveSurface())
            .cornerRadius(.radiusMedium)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.springSnappy) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.springSnappy) {
                        isPressed = false
                    }
                }
        )
    }
}

// MARK: - Activity Row
struct ActivityRow: View {
    let activity: ActivityItem
    
    var body: some View {
        HStack(alignment: .top, spacing: .spacingM) {
            Image(systemName: activity.type.icon)
                .font(.title3)
                .foregroundColor(activity.type.color)
                .frame(width: 32, height: 32)
                .background(activity.type.color.opacity(0.1))
                .cornerRadius(.radiusSmall)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.subhead)
                    .fontWeight(.semibold)
                    .foregroundColor(.adaptiveTextPrimary())
                
                Text(activity.message)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                Text(activity.timestamp, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Invitation Row
struct InvitationRow: View {
    let invitation: TeamInvitation
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Team Invitation")
                    .font(.subhead)
                    .fontWeight(.semibold)
                
                Text("\(invitation.inviterName) invited you to join \(invitation.teamName)")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            HStack(spacing: .spacingS) {
                Button("Decline") {
                    // Handle decline
                }
                .font(.caption)
                .foregroundColor(.error)
                
                PrimaryButton(title: "Accept", action: {
                    // Handle accept
                })
                .frame(width: 80, height: 32)
            }
        }
    }
}

#Preview {
    DashboardView(selectedTab: .constant(0))
        .environmentObject(AuthViewModel())
}
