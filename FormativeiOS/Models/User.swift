//
//  User.swift
//  FormativeiOS
//
//  Created on [Date]
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let username: String?
    let firstName: String?
    let lastName: String?
    let avatar: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email
        case username
        case firstName
        case lastName
        case avatar
        case createdAt
        case updatedAt
    }
}

struct AuthResponse: Codable {
    let token: String
    let user: User
    let expiresIn: Int?
}

struct LoginRequest: Codable {
    let email: String
    let password: String
    let rememberMe: Bool?
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let username: String?
    let firstName: String?
    let lastName: String?
}

