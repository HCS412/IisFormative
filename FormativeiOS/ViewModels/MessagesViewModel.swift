//
//  MessagesViewModel.swift
//  FormativeiOS
//
//  Messages View Model - Connects to Railway backend
//

import Foundation
import SwiftUI
import Combine

@MainActor
class MessagesViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var currentMessages: [Message] = []
    @Published var selectedConversationId: Int? = nil
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient = APIClient.shared

    func loadConversations() async {
        isLoading = true
        errorMessage = nil

        do {
            let response: ConversationsResponse = try await apiClient.request(
                endpoint: "/conversations"
            )
            conversations = response.conversations
        } catch let error as APIError {
            // If endpoint doesn't exist yet (404), show empty state gracefully
            if case .httpError(let statusCode) = error, statusCode == 404 {
                conversations = []
            } else {
                errorMessage = "Failed to load conversations"
            }
        } catch {
            // Network or other error - show empty state
            conversations = []
        }

        isLoading = false
    }

    func loadMessages(for conversationId: Int) async {
        isLoading = true
        errorMessage = nil

        do {
            let response: MessagesResponse = try await apiClient.request(
                endpoint: "/conversations/\(conversationId)/messages"
            )
            currentMessages = response.messages
            selectedConversationId = conversationId
        } catch let error as APIError {
            // If endpoint doesn't exist yet (404), show empty state
            if case .httpError(let statusCode) = error, statusCode == 404 {
                currentMessages = []
            } else {
                errorMessage = "Failed to load messages"
            }
        } catch {
            currentMessages = []
        }

        isLoading = false
    }

    func sendMessage(content: String, conversationId: Int?, recipientId: Int?) async -> Bool {
        do {
            let request = SendMessageRequest(
                conversationId: conversationId,
                recipientId: recipientId,
                content: content,
                attachments: nil
            )

            let body = try JSONEncoder().encode(request)
            let _: SendMessageResponse = try await apiClient.request(
                endpoint: "/messages",
                method: "POST",
                body: body
            )

            // Reload messages after sending
            if let conversationId = conversationId {
                await loadMessages(for: conversationId)
            }
            return true
        } catch {
            errorMessage = "Failed to send message"
            return false
        }
    }

    func startConversation(with userId: Int, message: String) async -> Int? {
        do {
            let request = SendMessageRequest(
                conversationId: nil,
                recipientId: userId,
                content: message,
                attachments: nil
            )

            let body = try JSONEncoder().encode(request)
            let response: SendMessageResponse = try await apiClient.request(
                endpoint: "/messages",
                method: "POST",
                body: body
            )

            // Reload conversations
            await loadConversations()

            return response.message?.conversationId
        } catch {
            errorMessage = "Failed to start conversation"
            return nil
        }
    }
}
