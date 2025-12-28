//
//  ChatView.swift
//  FormativeiOS
//
//  Chat View
//

import SwiftUI

struct ChatView: View {
    let conversation: Conversation
    @StateObject private var viewModel = MessagesViewModel()
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: .spacingM) {
                        ForEach(viewModel.currentMessages) { message in
                            MessageBubble(message: message, isCurrentUser: message.senderId == "current-user-id")
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
        .navigationTitle(conversation.participant.name)
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
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let content = messageText
        messageText = ""
        
        Task {
            await viewModel.sendMessage(
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
                            ? LinearGradient.brand
                            : LinearGradient(
                                colors: [Color.adaptiveSurface()],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                    )
                    .cornerRadius(.radiusMedium)
                    .overlay(
                        // Tail
                        MessageTail(isCurrentUser: isCurrentUser)
                            .fill(isCurrentUser ? AnyShapeStyle(LinearGradient.brand) : AnyShapeStyle(Color.adaptiveSurface()))
                            .frame(width: 8, height: 8)
                            .offset(x: isCurrentUser ? 4 : -4, y: 4)
                    )
                
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
            } else {
                // Avatar for sent messages
                Circle()
                    .fill(LinearGradient.brand)
                    .frame(width: 32, height: 32)
            }
        }
    }
    
    private func formatTime(_ timestamp: String) -> String {
        // Format time
        return "10:30 AM" // Simplified
    }
}

// MARK: - Message Tail Shape
struct MessageTail: Shape {
    let isCurrentUser: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        if isCurrentUser {
            // Right tail
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addQuadCurve(
                to: CGPoint(x: rect.minX, y: rect.minY),
                control: CGPoint(x: rect.minX - 4, y: rect.midY)
            )
        } else {
            // Left tail
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: rect.minY),
                control: CGPoint(x: rect.maxX + 4, y: rect.midY)
            )
        }
        
        path.closeSubpath()
        return path
    }
}

#Preview {
    NavigationStack {
        ChatView(conversation: Conversation(
            id: "1",
            participant: User(
                id: 1,
                name: "John Doe",
                email: "user@example.com",
                userType: "creator",
                profileData: nil,
                avatarUrl: nil,
                createdAt: nil,
                updatedAt: nil
            ),
            lastMessage: nil,
            unreadCount: 0,
            updatedAt: ""
        ))
    }
}

