//
//  SocialAccountsViewModel.swift
//  FormativeiOS
//
//  Social Accounts View Model - Connects to Railway backend for social media integration
//

import Foundation
import SwiftUI
import Combine
import AuthenticationServices

@MainActor
class SocialAccountsViewModel: ObservableObject {
    @Published var accounts: [SocialAccount] = []
    @Published var aggregatedStats: AggregatedSocialStats = AggregatedSocialStats()
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let apiClient = APIClient.shared

    // MARK: - Load Social Accounts
    func loadAccounts() async {
        isLoading = true
        errorMessage = nil

        do {
            let response: SocialAccountsResponse = try await apiClient.request(
                endpoint: "/user/social-accounts"
            )
            accounts = response.accounts
            calculateAggregatedStats()
        } catch let error as APIError {
            if case .httpError(let code) = error, code == 404 {
                // No accounts connected yet
                accounts = []
                aggregatedStats = AggregatedSocialStats()
            } else {
                errorMessage = "Failed to load social accounts"
            }
        } catch {
            errorMessage = "Network error loading accounts"
        }

        isLoading = false
    }

    // MARK: - Refresh Stats for Platform
    func refreshStats(for platform: SocialPlatform) async {
        isRefreshing = true
        errorMessage = nil

        do {
            let endpoint: String
            switch platform {
            case .twitter:
                endpoint = "/social/twitter/stats"
            case .youtube:
                endpoint = "/social/youtube/stats"
            case .bluesky:
                endpoint = "/social/bluesky/stats"
            case .instagram:
                endpoint = "/social/instagram/stats"
            case .tiktok:
                endpoint = "/social/tiktok/stats"
            case .other:
                isRefreshing = false
                return
            }

            let response: SocialStatsResponse = try await apiClient.request(
                endpoint: endpoint
            )

            // Update the account in our list
            if let updatedAccount = response.account {
                if let index = accounts.firstIndex(where: { $0.platform.lowercased() == platform.rawValue }) {
                    accounts[index] = updatedAccount
                }
            }

            calculateAggregatedStats()
            successMessage = "\(platform.displayName) stats refreshed"

        } catch {
            errorMessage = "Failed to refresh \(platform.displayName) stats"
        }

        isRefreshing = false
    }

    // MARK: - Refresh All Stats
    func refreshAllStats() async {
        isRefreshing = true
        errorMessage = nil

        // Refresh stats for each connected platform
        for account in accounts {
            await refreshStats(for: account.platformType)
        }

        isRefreshing = false
    }

    // MARK: - Verify Bluesky Account
    func verifyBluesky(handle: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let request = BlueskyVerifyRequest(handle: handle)
            let body = try JSONEncoder().encode(request)

            let response: BlueskyVerifyResponse = try await apiClient.request(
                endpoint: "/social/bluesky/verify",
                method: "POST",
                body: body
            )

            if response.success == true, let account = response.account {
                accounts.append(account)
                calculateAggregatedStats()
                successMessage = "Bluesky account verified"
                isLoading = false
                return true
            } else {
                errorMessage = response.message ?? "Failed to verify Bluesky handle"
            }
        } catch {
            errorMessage = "Failed to verify Bluesky account"
        }

        isLoading = false
        return false
    }

    // MARK: - Disconnect Account
    func disconnectAccount(platform: SocialPlatform) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let _: DisconnectAccountResponse = try await apiClient.request(
                endpoint: "/social/\(platform.rawValue)/disconnect",
                method: "DELETE"
            )

            accounts.removeAll { $0.platform.lowercased() == platform.rawValue }
            calculateAggregatedStats()
            successMessage = "\(platform.displayName) disconnected"
            isLoading = false
            return true
        } catch {
            errorMessage = "Failed to disconnect \(platform.displayName)"
        }

        isLoading = false
        return false
    }

    // MARK: - Get OAuth URL for Platform
    func getOAuthURL(for platform: SocialPlatform) -> URL? {
        let baseURL = "https://chic-patience-production.up.railway.app"

        // Get the auth token to pass to the OAuth flow
        guard let token = KeychainService.shared.getToken() else {
            errorMessage = "Please log in to connect social accounts"
            return nil
        }

        // Include token as query parameter so backend knows which user is connecting
        // Backend uses authenticateTokenFlexible which accepts token as query param
        let tokenParam = "token=\(token)"

        // Backend uses /api/oauth/{platform}/authorize endpoints
        switch platform {
        case .twitter:
            return URL(string: "\(baseURL)/api/oauth/twitter/authorize?\(tokenParam)")
        case .instagram:
            return URL(string: "\(baseURL)/api/oauth/instagram/authorize?\(tokenParam)")
        case .tiktok:
            return URL(string: "\(baseURL)/api/oauth/tiktok/authorize?\(tokenParam)")
        case .youtube:
            return URL(string: "\(baseURL)/api/oauth/youtube/authorize?\(tokenParam)")
        default:
            return nil
        }
    }

    // MARK: - Calculate Aggregated Stats
    private func calculateAggregatedStats() {
        var stats = AggregatedSocialStats()

        for account in accounts {
            if let accountStats = account.stats {
                stats.totalFollowers += accountStats.totalFollowers
                if let engagement = accountStats.engagementRate {
                    stats.totalEngagementRate += engagement
                }
            }
            stats.platformCount += 1
        }

        stats.accounts = accounts
        aggregatedStats = stats
    }

    // MARK: - Check if Platform Connected
    func isConnected(_ platform: SocialPlatform) -> Bool {
        accounts.contains { $0.platform.lowercased() == platform.rawValue }
    }

    // MARK: - Get Account for Platform
    func account(for platform: SocialPlatform) -> SocialAccount? {
        accounts.first { $0.platform.lowercased() == platform.rawValue }
    }
}
