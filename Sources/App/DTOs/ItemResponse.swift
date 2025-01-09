//
//  ItemResponse.swift
//  auto24
//
//  Created by Александр Меслюк on 06.01.2025.
//

import Vapor

struct ItemResponse: Content {
    var id: UUID
    var images: [ImageResponse]
    var model: String
    var category: String
    var regNumber: String?
    var make: String
    var vinNumber: String?
    var year: Int
    var price: Int
    var description: String?
    var color: String?
    var initialReg: String?
    var mileage: Int?
    var bodytype: String
    var power: Int
    var drivetrain: String
    var fuel: String
    var transmission: String
}

struct ImageResponse: Content {
    var id: UUID?
    var path: String
}
