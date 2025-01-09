//
//  PartialUpdateData.swift
//  auto24
//
//  Created by Александр Меслюк on 06.01.2025.
//

import Vapor

/// DTO для частичного обновления
struct PartialUpdateData: Content {
    var image: Data?
    var category: String?
    var bodytype: String?
    var make: String?
    var model: String?
    var year: Int?
    var initialReg: String?
    var regNumber: String?
    var vinNumber: String?
    var price: Int?
    var mileage: Int?
    var color: String?
    var power: Int?
    var transmission: String?
    var fuel: String?
    var drivetrain: String?
    var description: String?
}
