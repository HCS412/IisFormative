//
//  ConversationsListView.swift
//  FormativeiOS
//
//  Conversations List View - Connected to backend API
//

import SwiftUI

struct ConversationsListView: View {
    @StateObject private var viewModel = MessagesViewModel()
    @State private var searchText = ""

    var filteredConversations: [Conversation] {
        if searchText.isEmpty {
            return viewModel.conversations
        }
        return viewModel.conversations.filter { conversation in
            conversation.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.adaptiveBackground()
                    .ignoresSafeArea()

                if viewModel.isLoading && viewModel.conversations.isEmpty {
                    ProgressView()
                } else if filteredConversations.isEmpty {
                    EmptyStateView(
                        icon: "message",
                        title: "No Messages Yet",
                        message: "Start a conversation to connect with brands and creators.",
                        actionTitle: nil,
                        action: nil
                    )
                } else {
                    List {
                        ForEach(filteredConversations) { conversation in
                            NavigationLink(destination: ChatView(conversation: conversation)) {
                                ConversationRow(conversation: conversation)
                            }
                        }
                        .onDelete { indexSet in
                            // Handle delete
                        }
                    }
                    .listStyle(.plain)
                    .searchable(text: $searchText, prompt: "Search conversations")
                }
            }
            .navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {}) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .refreshable {
                await viewModel.loadConversations()
            }
            .task {
                await viewModel.loadConversations()
            }
        }
    }
}

// MARK: - Conversation Row
struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        HStack(spacing: .spacingM) {
            // Avatar
            if let avatarUrl = conversation.participantAvatar, let url = URL(string: avatarUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    avatarPlaceholder
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            } else {
                avatarPlaceholder
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.displayName)
                        .font(.subhead)
                        .fontWeight(.semibold)
                        .foregroundColor(.adaptiveTextPrimary())

                    Spacer()

                    if let lastMessageAt = conversation.lastMessageAt {
                        Text(formatTimestamp(lastMessageAt))
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                    }
                }

                HStack {
                    Text(conversation.lastMessagePreview)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)

                    Spacer()

                    if let unreadCount = conversation.unreadCount, unreadCount > 0 {
                        Text("\(unreadCount)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.brandPrimary)
                            .cornerRadius(.radiusFull)
                    }
                }
            }
        }
        .padding(.vertical, .spacingS)
    }

    private var avatarPlaceholder: some View {
        Circle()
            .fill(LinearGradient.brand)
            .overlay(
                Text(String(conversation.displayName.prefix(1)))
                    .font(.headline)
                    .foregroundColor(.white)
            )
    }

    private func formatTimestamp(_ timestamp: String) -> String {
        // Parse ISO8601 timestamp and format relative time
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: timestamp) else {
            // Try without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            guard let date = formatter.date(from: timestamp) else {
                return ""
            }
            return formatRelativeTime(from: date)
        }

        return formatRelativeTime(from: date)
    }

    private func formatRelativeTime(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)

        if interval < 60 {
            return "now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h"
        } else if interval < 604800 {
            let days = Int(interval / 86400)
            return "\(days)d"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}

#Preview {
    ConversationsListView()
}
