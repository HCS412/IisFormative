//
//  SocialAccount.swift
//  FormativeiOS
//
//  Social Account model matching Railway backend
//

import Foundation

// MARK: - Social Account Model (matches backend GET /api/user/social-accounts)
struct SocialAccount: Codable, Identifiable {
    // Backend returns: platform, username, stats, last_synced_at, is_verified, created_at
    // Note: Backend does NOT return 'id' - we use platform as unique identifier
    let platform: String
    let username: String?
    let stats: SocialStats?
    let lastSyncedAt: String?
    let isVerified: Bool?
    let createdAt: String?

    // Use platform as the unique identifier since backend doesn't return id
    var id: String { platform }

    // Computed properties
    var platformType: SocialPlatform {
        SocialPlatform(rawValue: platform.lowercased()) ?? .other
    }

    var displayUsername: String {
        if let username = username, !username.isEmpty {
            return "@\(username)"
        }
        return platform.capitalized
    }

    var formattedFollowers: String {
        guard let followers = stats?.followers ?? stats?.subscribers else { return "0" }
        return formatNumber(followers)
    }

    var formattedEngagement: String {
        guard let rate = stats?.engagementRate else { return "0%" }
        return String(format: "%.1f%%", rate)
    }

    private func formatNumber(_ num: Int) -> String {
        if num >= 1_000_000 {
            return String(format: "%.1fM", Double(num) / 1_000_000)
        } else if num >= 1_000 {
            return String(format: "%.1fK", Double(num) / 1_000)
        }
        return "\(num)"
    }
}

// MARK: - Social Stats
struct SocialStats: Codable {
    let followers: Int?
    let following: Int?
    let posts: Int?
    let tweets: Int?
    let videos: Int?
    let subscribers: Int?
    let engagementRate: Double?
    let displayName: String?
    let profileImage: String?
    let bio: String?
    let verified: Bool?

    // Unified post count across platforms
    var totalPosts: Int {
        posts ?? tweets ?? videos ?? 0
    }

    // For YouTube, subscribers = followers
    var totalFollowers: Int {
        followers ?? subscribers ?? 0
    }
}

// MARK: - Social Platform Enum
enum SocialPlatform: String, CaseIterable {
    case twitter = "twitter"
    case instagram = "instagram"
    case tiktok = "tiktok"
    case youtube = "youtube"
    case bluesky = "bluesky"
    case other = "other"

    var displayName: String {
        switch self {
        case .twitter: return "Twitter/X"
        case .instagram: return "Instagram"
        case .tiktok: return "TikTok"
        case .youtube: return "YouTube"
        case .bluesky: return "Bluesky"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .twitter: return "bird"
        case .instagram: return "camera"
        case .tiktok: return "music.note"
        case .youtube: return "play.rectangle"
        case .bluesky: return "cloud"
        case .other: return "link"
        }
    }

    var brandColor: String {
        switch self {
        case .twitter: return "#1DA1F2"
        case .instagram: return "#E4405F"
        case .tiktok: return "#000000"
        case .youtube: return "#FF0000"
        case .bluesky: return "#0085FF"
        case .other: return "#666666"
        }
    }

    var requiresOAuth: Bool {
        switch self {
        case .twitter, .instagram, .tiktok, .youtube:
            return true
        case .bluesky, .other:
            return false
        }
    }
}

// MARK: - API Response Models
struct SocialAccountsResponse: Codable {
    let success: Bool?
    let accounts: [SocialAccount]
}

struct SocialStatsResponse: Codable {
    let success: Bool?
    let account: SocialAccount?
    let stats: SocialStats?
    let message: String?
}

// MARK: - Bluesky Verification Request
struct BlueskyVerifyRequest: Codable {
    let handle: String
}

struct BlueskyVerifyResponse: Codable {
    let success: Bool?
    let account: SocialAccount?
    let message: String?
}

// MARK: - Disconnect Request
struct DisconnectAccountResponse: Codable {
    let success: Bool?
    let message: String?
}

// MARK: - Aggregated Stats (for dashboard display)
struct AggregatedSocialStats {
    var totalFollowers: Int = 0
    var totalEngagementRate: Double = 0.0
    var platformCount: Int = 0
    var accounts: [SocialAccount] = []

    var averageEngagement: Double {
        guard platformCount > 0 else { return 0 }
        return totalEngagementRate / Double(platformCount)
    }

    var formattedFollowers: String {
        if totalFollowers >= 1_000_000 {
            return String(format: "%.1fM", Double(totalFollowers) / 1_000_000)
        } else if totalFollowers >= 1_000 {
            return String(format: "%.1fK", Double(totalFollowers) / 1_000)
        }
        return "\(totalFollowers)"
    }

    var formattedEngagement: String {
        String(format: "%.1f%%", averageEngagement)
    }
}
