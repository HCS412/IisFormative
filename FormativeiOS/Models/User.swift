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

// MARK: - User Type Enum
enum UserType: String, CaseIterable, Codable {
    case creator = "creator"
    case brand = "brand"
    case agency = "agency"

    var displayName: String {
        switch self {
        case .creator: return "Creator"
        case .brand: return "Brand"
        case .agency: return "Agency"
        }
    }
}

// MARK: - Update Profile Request
struct UpdateProfileRequest: Codable {
    let name: String?
    let bio: String?
    let website: String?
    let location: String?

    init(name: String? = nil, bio: String? = nil, website: String? = nil, location: String? = nil) {
        self.name = name
        self.bio = bio
        self.website = website
        self.location = location
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
