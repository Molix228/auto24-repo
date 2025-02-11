import Fluent
import Vapor

final class Item: @unchecked Sendable, Model, Content {
    static let schema: String = "items"

    @ID var id: UUID?
    
    @Parent(key: "userId")
    var user: User

    @Field(key: "category") var category: String
    @Field(key: "bodytype") var bodytype: String
    @Field(key: "make") var make: String
    @Field(key: "model") var model: String
    @Field(key: "year") var year: Int
    @Field(key: "initial_reg") var initialReg: String?
    @Field(key: "reg_number") var regNumber: String?
    @Field(key: "vin_number") var vinNumber: String?
    @Field(key: "price") var price: Int
    @Field(key: "mileage") var mileage: Int?
    @Field(key: "color") var color: String?
    @Field(key: "power") var power: Int
    @Field(key: "transmission") var transmission: String
    @Field(key: "fuel") var fuel: String
    @Field(key: "drivetrain") var drivetrain: String
    @Field(key: "description") var description: String?

    @Children(for: \.$item) var images: [ItemImage]

    func willDelete(on database: Database) async throws {
        database.logger.info("Удаление изображений перед удалением объявления \(String(describing: self.id))")
        try await self.$images.query(on: database).delete()
    }

    init() {}

    init(id: UUID? = nil, userID: UUID, category: String, bodytype: String, make: String, model: String, year: Int,
         initialReg: String? = nil, regNumber: String? = nil, vinNumber: String? = nil, price: Int,
         mileage: Int? = nil, color: String? = nil, power: Int, transmission: String,
         fuel: String, drivetrain: String, description: String? = nil) {
        self.id = id
        self.$user.id = userID // ✅ Связь с пользователем
        self.category = category
        self.bodytype = bodytype
        self.make = make
        self.model = model
        self.year = year
        self.initialReg = initialReg
        self.regNumber = regNumber
        self.vinNumber = vinNumber
        self.price = price
        self.mileage = mileage
        self.color = color
        self.power = power
        self.transmission = transmission
        self.fuel = fuel
        self.drivetrain = drivetrain
        self.description = description
    }
}
