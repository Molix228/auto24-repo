//
//  CreateItemImage.swift
//  auto24
//
//  Created by Александр Меслюк on 06.01.2025.
//

import Fluent
import Vapor

struct CreateItemImage: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("item_images")
            .id()
            .field("item_id", .uuid, .required, .references("items", "id", onDelete: .cascade))
            .field("path", .string, .required)
            .create()
    }
    func revert(on database: Database) async throws {
        try await database.schema("item_images").delete()
    }
}
