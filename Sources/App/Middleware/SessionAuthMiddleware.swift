//
//  SessionAuthMiddleware.swift
//  auto24
//
//  Created by Александр Меслюк on 07.01.2025.
//

import Vapor

struct SessionAuthMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let userID = request.session.data["userID"], let _ = UUID(userID) else {
            throw Abort(.unauthorized, reason: "Access Denied")
        }

        return try await next.respond(to: request)
    }
}
