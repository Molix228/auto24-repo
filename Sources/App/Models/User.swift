//
//  User.swift
//  auto24
//
//  Created by Александр Меслюк on 14.11.2024.
//

import Vapor
import Fluent

final class User: @unchecked Sendable, Model, Content {
    static let schema: String = "users"
    @ID var id: UUID?
    @Field(key: "username") var username: String
    @Field(key: "email") var email: String
    @Field(key: "password") var password: String
    @Field(key: "role") var role: String
    @Field(key: "profileImage") var profileImage: String?
    init() {}
    init(id: UUID? = nil, username: String, email: String, password: String, role: String, profileImage: String? = nil) {
        self.id = id
        self.username = username
        self.email = email
        self.password = password
        self.role = role
        self.profileImage = profileImage
    }
    final class Public: Content {
        var id: UUID?
        var username: String
        var email: String
        var role: String
        var profileImage: String?
        init(id: UUID? = nil, username: String, email: String, role: String, profileImage: String? = nil) {
            self.id = id
            self.username = username
            self.email = email
            self.role = role
            self.profileImage = profileImage
        }
    }
}

extension User {
    func convertToPublic() -> User.Public {
        let pub = User.Public(id: self.id, username: self.username, email: self.email, role: self.role, profileImage: self.profileImage)
        return pub
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$username
    static let passwordHashKey = \User.$password
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}

enum UserRole: String {
    case user = "User"
    case admin = "Administrator"
}
