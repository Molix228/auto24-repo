//
//  SearchQuery.swift
//  auto24
//
//  Created by Александр Меслюк on 11.02.2025.
//

import Vapor

struct SearchQuery: Content {
    var make: String?
    var model: String?
    var year: Int?
    var minPrice: Int?
    var maxPrice: Int?
    var minMileage: Int?
    var maxMileage: Int?
}
