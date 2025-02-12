//
//  UsersController.swift
//  auto24
//
//  Created by Александр Меслюк on 14.11.2024.
//

import Fluent
import Vapor
import JWT

struct UsersController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        let authUsers = users.grouped(SessionAuthMiddleware())

        authUsers.get(use: index)
        authUsers.get("me", use: me)
        authUsers.group(":userID") { user in
            user.get(use: show)
            user.put(use: update)
            user.delete(use: delete)
        }
        
        users.post("login", use: login)
        users.post(use: create)
    }

    // ✅ **Метод для получения текущего пользователя**
    @Sendable func me(req: Request) async throws -> User.Public {
        guard let user = req.auth.get(User.self) else {
            throw Abort(.unauthorized, reason: "Not authenticated")
        }
        return user.convertToPublic()
    }

    // ✅ **Создание нового пользователя**
    @Sendable func create(req: Request) async throws -> User.Public {
        let formData = try req.content.decode(UserFormData.self)
        let user = User(
            username: formData.username,
            email: formData.email,
            password: try Bcrypt.hash(formData.password),
            role: formData.role,
            profileImage: formData.profileImage
        )
        try await user.save(on: req.db)
        return user.convertToPublic()
    }

    // ✅ **Аутентификация пользователя**
    @Sendable func login(req: Request) async throws -> Response {
        let loginData = try req.content.decode(LoginData.self)

        guard let user = try await User.query(on: req.db)
            .filter(\.$username == loginData.username)
            .first(),
              try Bcrypt.verify(loginData.password, created: user.password) else {
            throw Abort(.unauthorized)
        }

        let payload = try Payload(user: user)
        let token = try req.jwt.sign(payload)

        let userID = try user.requireID().uuidString

        let response = Response(status: .ok)
        response.headers.replaceOrAdd(name: .setCookie, value: "userID=\(userID); Path=/; HttpOnly; Secure; SameSite=Strict")
        response.headers.contentType = .json

        try response.content.encode(["token": token, "userID": userID])
        return response
    }

    // ✅ **Получение списка пользователей**
    @Sendable func index(req: Request) async throws -> [User.Public] {
        let users = try await User.query(on: req.db).all()
        return users.map { $0.convertToPublic() }
    }

    // ✅ **Получение пользователя по ID**
    @Sendable func show(req: Request) async throws -> User.Public {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return user.convertToPublic()
    }

    // ✅ **Обновление данных пользователя**
    @Sendable func update(req: Request) async throws -> User.Public {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        let updatedUserData = try req.content.decode(UpdatedUserData.self)
        if let username = updatedUserData.username { user.username = username }
        if let email = updatedUserData.email { user.email = email }
        if let password = updatedUserData.password {
            user.password = try Bcrypt.hash(password)
        }
        if let profileImage = updatedUserData.profileImage { user.profileImage = profileImage }
        try await user.save(on: req.db)
        return user.convertToPublic()
    }

    // ✅ **Удаление пользователя**
    @Sendable func delete(req: Request) async throws -> HTTPStatus {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await user.delete(on: req.db)
        return .ok
    }
}
struct UserFormData: Content {
    var username: String
    var email: String
    var password: String
    var role: String
    var profileImage: String?
}

struct TokenResponse: Content {
    let token: String
}
// Структура для данных входа
struct LoginData: Content {
    var username: String
    var password: String
}

struct Payload: JWTPayload {
    var userID: UUID
    var exp: ExpirationClaim
    
    init(user: User) throws {
        self.userID = try user.requireID()
        self.exp = .init(value: Date().addingTimeInterval(3600)) // Токен на 1 час
    }

    func verify(using signer: JWTSigner) throws {
        try self.exp.verifyNotExpired()
    }
}
struct UpdatedUserData: Content {
    var username: String?
    var email: String?
    var password: String?
    var profileImage: String?
}
