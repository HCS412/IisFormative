//
//  NotificationsView.swift
//  FormativeiOS
//
//  Notifications View
//

import SwiftUI
import Combine

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()
    @State private var selectedFilter: FilterOption = .all
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case unread = "Unread"
    }
    
    var filteredNotifications: [AppNotification] {
        let notifications = viewModel.notifications
        
        switch selectedFilter {
        case .all:
            return notifications
        case .unread:
            return notifications.filter { !$0.isRead }
        }
    }
    
    var groupedNotifications: [String: [AppNotification]] {
        Dictionary(grouping: filteredNotifications) { notification in
            formatDateGroup(notification.createdAt)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.adaptiveBackground()
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.notifications.isEmpty {
                    ProgressView()
                } else if filteredNotifications.isEmpty {
                    EmptyStateView(
                        icon: "bell.slash",
                        title: "No Notifications",
                        message: selectedFilter == .unread
                            ? "You're all caught up! No unread notifications."
                            : "You don't have any notifications yet.",
                        actionTitle: nil,
                        action: nil
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: .spacing2XL) {
                            ForEach(Array(groupedNotifications.keys.sorted(by: >)), id: \.self) { dateGroup in
                                VStack(alignment: .leading, spacing: .spacingM) {
                                    Text(dateGroup)
                                        .font(.subhead)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.textSecondary)
                                        .padding(.horizontal, .spacingL)
                                    
                                    ForEach(groupedNotifications[dateGroup] ?? []) { notification in
                                        NotificationRow(notification: notification)
                                            .padding(.horizontal, .spacingL)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, .spacingL)
                    }
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        ForEach(FilterOption.allCases, id: \.self) { option in
                            Button(action: {
                                selectedFilter = option
                            }) {
                                HStack {
                                    Text(option.rawValue)
                                    if selectedFilter == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                        
                        Divider()
                        
                        Button(action: {
                            Task {
                                await viewModel.markAllAsRead()
                            }
                        }) {
                            Label("Mark All as Read", systemImage: "checkmark.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .refreshable {
                await viewModel.loadNotifications()
            }
            .task {
                await viewModel.loadNotifications()
            }
        }
    }
    
    private func formatDateGroup(_ dateString: String) -> String {
        // Format as "Today", "Yesterday", or date
        return "Today" // Simplified
    }
}

// MARK: - Notification Row
struct NotificationRow: View {
    let notification: AppNotification
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            Haptics.selection()
            // Handle notification tap
        }) {
            HStack(spacing: .spacingM) {
                // Icon
                Image(systemName: notification.type.icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(notification.type.color)
                    .cornerRadius(.radiusMedium)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.subhead)
                        .fontWeight(.semibold)
                        .foregroundColor(.adaptiveTextPrimary())
                    
                    Text(notification.message)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Unread indicator
                if !notification.isRead {
                    Circle()
                        .fill(Color.brandPrimary)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.spacingM)
            .background(notification.isRead ? Color.adaptiveSurface() : Color.brandPrimary.opacity(0.05))
            .cornerRadius(.radiusMedium)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: {
                // Delete notification
            }) {
                Label("Delete", systemImage: "trash")
            }
            
            if !notification.isRead {
                Button(action: {
                    // Mark as read
                }) {
                    Label("Mark Read", systemImage: "checkmark")
                }
                .tint(.brandPrimary)
            }
        }
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

// MARK: - Notifications View Model
@MainActor
class NotificationsViewModel: ObservableObject {
    @Published var notifications: [AppNotification] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient.shared
    
    func loadNotifications() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Mock data - replace with actual API call
            notifications = []
        } catch {
            errorMessage = "Failed to load notifications: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func markAllAsRead() async {
        // API call to mark all as read
        notifications = notifications.map { notification in
            var updated = notification
            // Update isRead to true
            return updated
        }
    }
}

#Preview {
    NotificationsView()
}

