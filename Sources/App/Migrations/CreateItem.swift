//
//  CreateItem.swift
//  auto24
//
//  Created by Александр Меслюк on 14.11.2024.
//

import Fluent
import Vapor

struct CreateItem: AsyncMigration {
    func prepare(on database: any FluentKit.Database) async throws {
        let schema = database.schema("items")
            .id()
            .field("userId", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("image", .string)
            .field("category", .string, .required)
            .field("bodytype", .string, .required)
            .field("make", .string, .required)
            .field("model", .string, .required)
            .field("year", .int, .required)
            .field("initial_reg", .string)
            .field("reg_number", .string)
            .field("vin_number", .string)
            .field("price", .int, .required)
            .field("mileage", .int)
            .field("color", .string)
            .field("power", .int, .required)
            .field("transmission", .string, .required)
            .field("fuel", .string, .required)
            .field("drivetrain", .string, .required)
            .field("description", .string)
            try await schema.create()
    }
    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema("items").delete()
    }

}
