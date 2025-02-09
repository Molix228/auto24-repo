import Fluent
import Vapor

struct ItemsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let items = routes.grouped("items")
        items.get(use: index)
        items.group(":itemID") { item in
            item.get(use: show)
            item.put(use: update)
            item.delete(use: delete)
        }
        let basicMW = User.authenticator()
        let guardMW = User.guardMiddleware()
        let protected = items.grouped(basicMW, guardMW)
        protected.post(use: create)
    }

    @Sendable func create(req: Request) async throws -> Item {
        let formData = try req.content.decode(ItemFormData.self)
        let item = Item(
            category: formData.category,
            bodytype: formData.bodytype,
            make: formData.make,
            model: formData.model,
            year: formData.year,
            initialReg: formData.initialReg,
            regNumber: formData.regNumber,
            vinNumber: formData.vinNumber,
            price: formData.price,
            mileage: formData.mileage,
            color: formData.color,
            power: formData.power,
            transmission: formData.transmission,
            fuel: formData.fuel,
            drivetrain: formData.drivetrain,
            description: formData.description
        )
        try await item.save(on: req.db)
        
        let itemID = try item.requireID().uuidString
        let storageFolder = "/app/Storage/Items/\(itemID)"
        if !FileManager.default.fileExists(atPath: storageFolder) {
            try FileManager.default.createDirectory(atPath: storageFolder, withIntermediateDirectories: true)
        }
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for imageData in formData.images {
                group.addTask {
                    let fileName = "\(UUID()).jpg"
                    let fullPath = storageFolder + "/" + fileName
                    try await req.fileio.writeFile(.init(data: imageData), at: fullPath)
                    let itemImage = ItemImage(itemID: try item.requireID(), path: fullPath)
                    try await itemImage.save(on: req.db)
                }
            }
            try await group.waitForAll()
        }
        
        return item
    }

    @Sendable func index(req: Request) async throws -> [Item] {
        try await Item.query(on: req.db).with(\.$images).all()
    }
    @Sendable func show(req: Request) async throws -> ItemResponse {
        guard let itemID = req.parameters.get("itemID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing itemID")
        }
        guard let item = try await Item.query(on: req.db)
            .with(\.$images)
            .filter(\.$id == itemID)
            .first()
        else {
            throw Abort(.notFound)
        }
        let images = item.images.map { ImageResponse(id: $0.id, path: $0.path) }
        return ItemResponse(
            id: item.id!,
            images: images,
            model: item.model,
            category: item.category,
            regNumber: item.regNumber,
            make: item.make,
            vinNumber: item.vinNumber,
            year: item.year,
            price: item.price,
            description: item.description,
            color: item.color,
            initialReg: item.initialReg,
            mileage: item.mileage,
            bodytype: item.bodytype,
            power: item.power,
            drivetrain: item.drivetrain,
            fuel: item.fuel,
            transmission: item.transmission
        )
    }
    @Sendable func update(req: Request) async throws -> Item {
        guard let item = try await Item.find(req.parameters.get("itemID"), on: req.db) else {
            throw Abort(.notFound)
        }
        let updateData = try req.content.decode(PartialUpdateData.self)
        if let imageData = updateData.image {
            let itemID = try item.requireID().uuidString
            let storageFolder = req.application.directory.workingDirectory + "Storage/Items/\(itemID)"
            let newImagePath = storageFolder + "/" + "\(UUID()).jpg"
            req.logger.debug("Updating file at \(newImagePath)")
            try await req.fileio.writeFile(.init(data: imageData), at: newImagePath)
        }
        updateFields(item, with: updateData)
        try await item.save(on: req.db)
        return item
    }
    @Sendable func delete(req: Request) async throws -> HTTPStatus {
        guard let item = try await Item.find(req.parameters.get("itemID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await item.$images.query(on: req.db).delete()
        try await item.delete(on: req.db)
        return .ok
    }
    private func updateFields(_ item: Item, with data: PartialUpdateData) {
        if let category = data.category { item.category = category }
        if let bodytype = data.bodytype { item.bodytype = bodytype }
        if let make = data.make { item.make = make }
        if let model = data.model { item.model = model }
        if let year = data.year { item.year = year }
        if let initialReg = data.initialReg { item.initialReg = initialReg }
        if let regNumber = data.regNumber { item.regNumber = regNumber }
        if let vinNumber = data.vinNumber { item.vinNumber = vinNumber }
        if let price = data.price { item.price = price }
        if let mileage = data.mileage { item.mileage = mileage }
        if let color = data.color { item.color = color }
        if let power = data.power { item.power = power }
        if let transmission = data.transmission { item.transmission = transmission }
        if let fuel = data.fuel { item.fuel = fuel }
        if let drivetrain = data.drivetrain { item.drivetrain = drivetrain }
        if let description = data.description { item.description = description }
    }
}
