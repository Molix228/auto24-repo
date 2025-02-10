import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get("check-directory") { _ -> String in
        let currentDirectoryPath = FileManager.default.currentDirectoryPath
        return "Current working directory: \(currentDirectoryPath)"
    }
    try app.register(collection: ItemsController())
    try app.register(collection: UsersController())
}
