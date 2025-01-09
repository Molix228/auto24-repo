//
//  CreateUser.swift
//  auto24
//
//  Created by Александр Меслюк on 14.11.2024.
//

import Vapor
import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: any FluentKit.Database) async throws {
        let schema = database.schema("users")
            .id()
            .field("username", .string, .required)
            .field("email", .string, .required)
            .field("password", .string, .required)
            .field("role", .string, .required)
            .field("profileImage", .string)
            .unique(on: "username")
        try await schema.create()
    }
    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema("users").delete()
    }  
}
