//
//  ChatView.swift
//  FormativeiOS
//
//  Chat View - Connected to backend API
//

import SwiftUI

struct ChatView: View {
    let conversation: Conversation
    @StateObject private var viewModel = MessagesViewModel()
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: .spacingM) {
                        ForEach(viewModel.currentMessages) { message in
                            MessageBubble(
                                message: message,
                                isCurrentUser: isFromCurrentUser(message)
                            )
                            .id(message.id)
                        }
                    }
                    .padding(.spacingL)
                }
                .onChange(of: viewModel.currentMessages.count) { _, _ in
                    if let lastMessage = viewModel.currentMessages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Message Input
            messageInputBar
        }
        .background(Color.adaptiveBackground())
        .navigationTitle(conversation.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {}) {
                    Image(systemName: "info.circle")
                }
            }
        }
        .task {
            await viewModel.loadMessages(for: conversation.id)
        }
    }

    // MARK: - Message Input Bar
    private var messageInputBar: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: .spacingM) {
                Button(action: {}) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.brandPrimary)
                }

                TextField("Type a message...", text: $messageText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(.spacingM)
                    .background(Color.adaptiveSurface())
                    .cornerRadius(.radiusMedium)
                    .focused($isInputFocused)
                    .lineLimit(1...5)

                Button(action: sendMessage) {
                    Image(systemName: messageText.isEmpty ? "arrow.up.circle.fill" : "paperplane.fill")
                        .font(.title2)
                        .foregroundColor(messageText.isEmpty ? .textSecondary : .brandPrimary)
                }
                .disabled(messageText.isEmpty)
            }
            .padding(.spacingL)
            .background(Color.adaptiveBackground())
        }
    }

    private func isFromCurrentUser(_ message: Message) -> Bool {
        guard let currentUserId = authViewModel.currentUser?.id else {
            return false
        }
        return message.senderId == currentUserId
    }

    private func sendMessage() {
        guard !messageText.isEmpty else { return }

        let content = messageText
        messageText = ""

        Task {
            let _ = await viewModel.sendMessage(
                content: content,
                conversationId: conversation.id,
                recipientId: nil
            )
        }

        Haptics.impact(.light)
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: .spacingS) {
            if !isCurrentUser {
                // Avatar for received messages
                Circle()
                    .fill(LinearGradient.brand)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(String((message.senderName ?? "U").prefix(1)))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    )
            } else {
                Spacer()
            }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundColor(isCurrentUser ? .white : .adaptiveTextPrimary())
                    .padding(.spacingM)
                    .background(
                        isCurrentUser
                            ? AnyShapeStyle(LinearGradient.brand)
                            : AnyShapeStyle(Color.adaptiveSurface())
                    )
                    .cornerRadius(.radiusMedium)

                HStack(spacing: 4) {
                    Text(formatTime(message.createdAt))
                        .font(.caption2)
                        .foregroundColor(.textSecondary)

                    if isCurrentUser {
                        if message.readAt != nil {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.brandPrimary)
                        } else if message.deliveredAt != nil {
                            Image(systemName: "checkmark.circle")
                                .font(.caption2)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: isCurrentUser ? .trailing : .leading)

            if isCurrentUser {
                Spacer()
            }
        }
    }

    private func formatTime(_ timestamp: String?) -> String {
        guard let timestamp = timestamp else { return "" }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: timestamp) else {
            formatter.formatOptions = [.withInternetDateTime]
            guard let date = formatter.date(from: timestamp) else {
                return ""
            }
            return formatTimeOnly(from: date)
        }

        return formatTimeOnly(from: date)
    }

    private func formatTimeOnly(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        ChatView(conversation: Conversation(
            id: 1,
            participantId: 2,
            participantName: "John Doe",
            participantAvatar: nil,
            lastMessageContent: "Hello!",
            lastMessageAt: nil,
            unreadCount: 0,
            createdAt: nil,
            updatedAt: nil
        ))
        .environmentObject(AuthViewModel())
    }
}
