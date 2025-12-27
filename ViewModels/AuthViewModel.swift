//
//  AuthViewModel.swift
//  FormativeiOS
//
//  Created on [Date]
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient.shared
    private let keychainService = KeychainService.shared
    
    init() {
        // Check if user is already authenticated
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        if let token = keychainService.getToken(), !token.isEmpty {
            // Token exists, verify it's still valid by fetching profile
            Task {
                await loadProfile()
            }
        }
    }
    
    func login(email: String, password: String, rememberMe: Bool = false) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let loginRequest = LoginRequest(email: email, password: password, rememberMe: rememberMe)
            let body = try JSONEncoder().encode(loginRequest)
            
            let response: AuthResponse = try await apiClient.request(
                endpoint: "/auth/login",
                method: "POST",
                body: body
            )
            
            // Save token to keychain
            if keychainService.saveToken(response.token) {
                currentUser = response.user
                isAuthenticated = true
            } else {
                errorMessage = "Failed to save authentication token"
            }
        } catch {
            errorMessage = "Login failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func register(email: String, password: String, username: String? = nil, firstName: String? = nil, lastName: String? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let registerRequest = RegisterRequest(
                email: email,
                password: password,
                username: username,
                firstName: firstName,
                lastName: lastName
            )
            let body = try JSONEncoder().encode(registerRequest)
            
            let response: AuthResponse = try await apiClient.request(
                endpoint: "/auth/register",
                method: "POST",
                body: body
            )
            
            // Save token to keychain
            if keychainService.saveToken(response.token) {
                currentUser = response.user
                isAuthenticated = true
            } else {
                errorMessage = "Failed to save authentication token"
            }
        } catch {
            errorMessage = "Registration failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func logout() {
        keychainService.deleteToken()
        currentUser = nil
        isAuthenticated = false
    }
    
    func loadProfile() async {
        do {
            let user: User = try await apiClient.request(endpoint: "/user/profile")
            currentUser = user
            isAuthenticated = true
        } catch {
            // Token might be invalid, logout
            logout()
        }
    }
}

