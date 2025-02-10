//
//  ItemImage.swift
//  auto24
//
//  Created by Александр Меслюк on 06.01.2025.
//

import Vapor
import Fluent

final class ItemImage: @unchecked Sendable, Model, Content {
    static let schema = "item_images"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "item_id")
    var item: Item

    @Field(key: "path")
    var path: String

    init() {}

    init(id: UUID? = nil, itemID: UUID, path: String) {
        self.id = id
        self.$item.id = itemID
        self.path = path
    }
}
