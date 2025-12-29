//
//  AuthViewModel.swift
//  FormativeiOS
//
//  Authentication ViewModel - connects to Railway backend
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
    @Published var requires2FA = false
    @Published var pending2FAUserId: Int?

    private let apiClient = APIClient.shared
    private let keychainService = KeychainService.shared

    init() {
        checkAuthStatus()
    }

    func checkAuthStatus() {
        if let token = keychainService.getToken(), !token.isEmpty {
            Task {
                await loadProfile()
            }
        }
    }

    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        requires2FA = false

        do {
            let loginRequest = LoginRequest(email: email, password: password)
            let body = try JSONEncoder().encode(loginRequest)

            let response: AuthResponse = try await apiClient.request(
                endpoint: "/auth/login",
                method: "POST",
                body: body
            )

            // Check if 2FA is required
            if response.requires2FA == true, let userId = response.userId {
                requires2FA = true
                pending2FAUserId = userId
                isLoading = false
                return
            }

            // Direct login (no 2FA)
            if let token = response.token, let user = response.user {
                if keychainService.saveToken(token) {
                    currentUser = user
                    isAuthenticated = true
                } else {
                    errorMessage = "Failed to save authentication token"
                }
            }
        } catch let error as APIError {
            errorMessage = "Login failed: \(error.localizedDescription)"
        } catch {
            errorMessage = "Login failed: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func verify2FA(code: String) async {
        guard let userId = pending2FAUserId else {
            errorMessage = "No pending 2FA verification"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let request = Verify2FARequest(userId: userId, code: code)
            let body = try JSONEncoder().encode(request)

            let response: AuthResponse = try await apiClient.request(
                endpoint: "/auth/2fa/login",
                method: "POST",
                body: body
            )

            if let token = response.token, let user = response.user {
                if keychainService.saveToken(token) {
                    currentUser = user
                    isAuthenticated = true
                    requires2FA = false
                    pending2FAUserId = nil
                } else {
                    errorMessage = "Failed to save authentication token"
                }
            }
        } catch let error as APIError {
            errorMessage = "Verification failed: \(error.localizedDescription)"
        } catch {
            errorMessage = "Verification failed: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func cancel2FA() {
        requires2FA = false
        pending2FAUserId = nil
        errorMessage = nil
    }

    func register(name: String, email: String, password: String, userType: UserType) async {
        isLoading = true
        errorMessage = nil

        do {
            let registerRequest = RegisterRequest(
                name: name,
                email: email,
                password: password,
                userType: userType.rawValue
            )
            let body = try JSONEncoder().encode(registerRequest)

            let response: AuthResponse = try await apiClient.request(
                endpoint: "/auth/register",
                method: "POST",
                body: body
            )

            if let token = response.token, let user = response.user {
                if keychainService.saveToken(token) {
                    currentUser = user
                    isAuthenticated = true
                } else {
                    errorMessage = "Failed to save authentication token"
                }
            }
        } catch let error as APIError {
            errorMessage = "Registration failed: \(error.localizedDescription)"
        } catch {
            errorMessage = "Registration failed: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func logout() {
        keychainService.deleteToken()
        currentUser = nil
        isAuthenticated = false
        requires2FA = false
        pending2FAUserId = nil
    }

    func loadProfile() async {
        do {
            let user: User = try await apiClient.request(endpoint: "/user/profile")
            currentUser = user
            isAuthenticated = true
        } catch {
            logout()
        }
    }

    func updateProfile(name: String?, bio: String?, website: String?, location: String?) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let request = UpdateProfileRequest(
                name: name,
                bio: bio,
                website: website,
                location: location
            )
            let body = try JSONEncoder().encode(request)

            let response: UpdateProfileResponse = try await apiClient.request(
                endpoint: "/user/profile",
                method: "PUT",
                body: body
            )

            // Update local user if response contains updated user
            if let updatedUser = response.user {
                currentUser = updatedUser
            } else {
                // Reload profile to get latest data
                await loadProfile()
            }

            isLoading = false
            return true
        } catch let error as APIError {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
            isLoading = false
            return false
        } catch {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
}
