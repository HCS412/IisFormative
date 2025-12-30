//
//  User.swift
//  FormativeiOS
//
//  User model and authentication types matching backend API
//

import Foundation

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let userType: String?
    let profileData: ProfileData?
    let avatarUrl: String?
    let createdAt: String?
    let updatedAt: String?

    // Computed property for display name compatibility
    var displayName: String {
        name
    }

    // Computed property for avatar URL compatibility
    var avatar: String? {
        avatarUrl
    }
}

// MARK: - Profile Data
struct ProfileData: Codable {
    let bio: String?
    let website: String?
    let location: String?
    let socialLinks: [String: String]?
    let calendlyUrl: String?
}

// MARK: - Auth Response (matches backend format)
struct AuthResponse: Codable {
    let user: User?
    let token: String?
    let requires2FA: Bool?
    let userId: Int?
}

// MARK: - 2FA Verify Request
struct Verify2FARequest: Codable {
    let userId: Int
    let code: String
}

// MARK: - Login Request
struct LoginRequest: Codable {
    let email: String
    let password: String
}

// MARK: - Register Request (matches backend format)
struct RegisterRequest: Codable {
    let name: String
    let email: String
    let password: String
    let userType: String
}

// MARK: - Apple Sign In Request
struct AppleSignInRequest: Codable {
    let identityToken: String
    let userIdentifier: String
    let email: String?
    let name: String?
}

// MARK: - User Type Enum (matches backend: influencer, brand, freelancer)
enum UserType: String, CaseIterable, Codable {
    case influencer = "influencer"
    case brand = "brand"
    case freelancer = "freelancer"

    var displayName: String {
        switch self {
        case .influencer: return "Influencer"
        case .brand: return "Brand"
        case .freelancer: return "Freelancer"
        }
    }

    var icon: String {
        switch self {
        case .influencer: return "person.crop.circle.badge.checkmark"
        case .brand: return "building.2.fill"
        case .freelancer: return "hammer.fill"
        }
    }
}

// MARK: - Update Profile Request (matches backend PUT /user/profile)
struct UpdateProfileRequest: Codable {
    let name: String?
    let bio: String?
    let website: String?
    let location: String?
    let avatarUrl: String?
    let profileData: ProfileDataUpdate?

    init(name: String? = nil, bio: String? = nil, website: String? = nil, location: String? = nil, avatarUrl: String? = nil, calendlyUrl: String? = nil) {
        self.name = name
        self.bio = bio
        self.website = website
        self.location = location
        self.avatarUrl = avatarUrl
        // calendlyUrl goes inside profileData JSONB
        if calendlyUrl != nil {
            self.profileData = ProfileDataUpdate(calendlyUrl: calendlyUrl)
        } else {
            self.profileData = nil
        }
    }
}

// MARK: - Profile Data Update (for JSONB fields)
struct ProfileDataUpdate: Codable {
    let calendlyUrl: String?
    let socialLinks: [String: String]?

    init(calendlyUrl: String? = nil, socialLinks: [String: String]? = nil) {
        self.calendlyUrl = calendlyUrl
        self.socialLinks = socialLinks
    }
}

// MARK: - User Profile Response (for GET /user/profile)
struct UserProfileResponse: Codable {
    let success: Bool?
    let user: User?
}

// MARK: - Update Profile Response
struct UpdateProfileResponse: Codable {
    let success: Bool?
    let user: User?
    let message: String?
}
