//
//  ConversationsListView.swift
//  FormativeiOS
//
//  Conversations List View
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
            conversation.participant.email.localizedCaseInsensitiveContains(searchText) ||
            (conversation.participant.username?.localizedCaseInsensitiveContains(searchText) ?? false)
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
                        actionTitle: "New Message",
                        action: {}
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
            AsyncImage(url: URL(string: conversation.participant.avatar ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(LinearGradient.brand)
                    .overlay(
                        Text(String((conversation.participant.email.prefix(1))))
                            .font(.headline)
                            .foregroundColor(.white)
                    )
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.adaptiveBackground(), lineWidth: 2)
            )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.participant.username ?? conversation.participant.email)
                        .font(.subhead)
                        .fontWeight(.semibold)
                        .foregroundColor(.adaptiveTextPrimary())
                    
                    Spacer()
                    
                    if let lastMessage = conversation.lastMessage {
                        Text(formatTimestamp(lastMessage.createdAt))
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                HStack {
                    if let lastMessage = conversation.lastMessage {
                        Text(lastMessage.content)
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                    } else {
                        Text("No messages yet")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                            .italic()
                    }
                    
                    Spacer()
                    
                    if conversation.unreadCount > 0 {
                        Text("\(conversation.unreadCount)")
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
    
    private func formatTimestamp(_ timestamp: String) -> String {
        // Format relative time
        return "2m ago" // Simplified
    }
}

#Preview {
    ConversationsListView()
}

