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
    @State private var showNewMessage = false

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
                        icon: "message.fill",
                        title: "No Messages Yet",
                        message: "Start a conversation to connect with brands and creators.",
                        actionTitle: "New Message",
                        action: { showNewMessage = true }
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
                    Button(action: {
                        Haptics.selection()
                        showNewMessage = true
                    }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showNewMessage) {
                NewMessageView(viewModel: viewModel, onConversationStarted: { conversationId in
                    showNewMessage = false
                })
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

// MARK: - New Message View
struct NewMessageView: View {
    @ObservedObject var viewModel: MessagesViewModel
    let onConversationStarted: (Int) -> Void
    @Environment(\.dismiss) var dismiss

    @State private var searchText = ""
    @State private var messageText = ""
    @State private var selectedUser: SearchedUser?
    @State private var searchResults: [SearchedUser] = []
    @State private var isSearching = false
    @State private var isSending = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Recipient Selection
                if selectedUser == nil {
                    // Search Field
                    HStack {
                        Text("To:")
                            .font(.subhead)
                            .foregroundColor(.textSecondary)

                        TextField("Search users...", text: $searchText)
                            .textFieldStyle(.plain)
                            .autocapitalization(.none)
                            .onChange(of: searchText) { _, newValue in
                                searchUsers(query: newValue)
                            }
                    }
                    .padding(.spacingM)
                    .background(Color.adaptiveSurface())

                    Divider()

                    // Search Results
                    if isSearching {
                        ProgressView()
                            .padding(.spacingXL)
                    } else if !searchResults.isEmpty {
                        List(searchResults) { user in
                            Button(action: {
                                selectedUser = user
                                searchText = ""
                                searchResults = []
                                Haptics.selection()
                            }) {
                                HStack(spacing: .spacingM) {
                                    Circle()
                                        .fill(LinearGradient.brand)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Text(String(user.name.prefix(1)))
                                                .font(.subhead)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                        )

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(user.name)
                                            .font(.subhead)
                                            .fontWeight(.medium)
                                            .foregroundColor(.adaptiveTextPrimary())

                                        if let userType = user.userType {
                                            Text(userType.capitalized)
                                                .font(.caption)
                                                .foregroundColor(.textSecondary)
                                        }
                                    }

                                    Spacer()
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .listStyle(.plain)
                    } else if !searchText.isEmpty {
                        VStack(spacing: .spacingM) {
                            Spacer()
                            Image(systemName: "person.slash")
                                .font(.system(size: 40))
                                .foregroundColor(.textSecondary.opacity(0.5))
                            Text("No users found")
                                .font(.subhead)
                                .foregroundColor(.textSecondary)
                            Spacer()
                        }
                    } else {
                        VStack(spacing: .spacingM) {
                            Spacer()
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(.textSecondary.opacity(0.5))
                            Text("Search for a user to message")
                                .font(.subhead)
                                .foregroundColor(.textSecondary)
                            Spacer()
                        }
                    }
                } else {
                    // Selected User & Message Input
                    VStack(spacing: 0) {
                        // Selected recipient
                        HStack {
                            Text("To:")
                                .font(.subhead)
                                .foregroundColor(.textSecondary)

                            HStack(spacing: .spacingS) {
                                Text(selectedUser?.name ?? "")
                                    .font(.subhead)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)

                                Button(action: {
                                    selectedUser = nil
                                    Haptics.selection()
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .padding(.horizontal, .spacingM)
                            .padding(.vertical, .spacingS)
                            .background(LinearGradient.brand)
                            .cornerRadius(.radiusFull)

                            Spacer()
                        }
                        .padding(.spacingM)
                        .background(Color.adaptiveSurface())

                        Divider()

                        // Message Input
                        VStack(alignment: .leading, spacing: .spacingM) {
                            Text("Message")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                                .padding(.horizontal, .spacingM)
                                .padding(.top, .spacingM)

                            TextEditor(text: $messageText)
                                .frame(minHeight: 150)
                                .padding(.spacingM)
                                .background(Color.adaptiveSurface())
                                .cornerRadius(.radiusSmall)
                                .overlay(
                                    RoundedRectangle(cornerRadius: .radiusSmall)
                                        .stroke(Color.separator, lineWidth: 1)
                                )
                                .padding(.horizontal, .spacingM)
                        }

                        Spacer()
                    }
                }
            }
            .background(Color.adaptiveBackground())
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSending)
                }

                ToolbarItem(placement: .confirmationAction) {
                    if isSending {
                        ProgressView()
                    } else {
                        Button("Send") {
                            sendMessage()
                        }
                        .fontWeight(.semibold)
                        .disabled(selectedUser == nil || messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
    }

    private func searchUsers(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        isSearching = true

        Task {
            do {
                let response: UsersSearchResponse = try await APIClient.shared.request(
                    endpoint: "/users/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)"
                )
                searchResults = response.users
            } catch {
                // If search endpoint doesn't exist, show empty results
                searchResults = []
            }
            isSearching = false
        }
    }

    private func sendMessage() {
        guard let user = selectedUser else { return }

        isSending = true

        Task {
            if let conversationId = await viewModel.startConversation(with: user.id, message: messageText) {
                Haptics.notification(.success)
                onConversationStarted(conversationId)
            } else {
                Haptics.notification(.error)
                isSending = false
            }
        }
    }
}

// MARK: - User Search Models
struct SearchedUser: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String?
    let userType: String?
    let avatarUrl: String?
}

struct UsersSearchResponse: Codable {
    let success: Bool?
    let users: [SearchedUser]
}

#Preview {
    ConversationsListView()
}
