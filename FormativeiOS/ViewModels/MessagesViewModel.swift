//
//  MessagesViewModel.swift
//  FormativeiOS
//
//  Messages View Model
//

import Foundation
import SwiftUI
import Combine

@MainActor
class MessagesViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var currentMessages: [Message] = []
    @Published var selectedConversationId: String? = nil
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient.shared
    
    func loadConversations() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Mock data - replace with actual API call
            conversations = []
        } catch {
            errorMessage = "Failed to load conversations: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func loadMessages(for conversationId: String) async {
        isLoading = true
        
        do {
            // Mock data - replace with actual API call
            currentMessages = []
            selectedConversationId = conversationId
        } catch {
            errorMessage = "Failed to load messages: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func sendMessage(content: String, conversationId: String?, recipientId: String?) async {
        do {
            let request = SendMessageRequest(
                conversationId: conversationId,
                recipientId: recipientId,
                content: content,
                attachments: nil
            )
            
            let body = try JSONEncoder().encode(request)
            // API call here
            // After success, reload messages
            if let conversationId = conversationId {
                await loadMessages(for: conversationId)
            }
        } catch {
            errorMessage = "Failed to send message: \(error.localizedDescription)"
        }
    }
}

