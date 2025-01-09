import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "admin",
        password: Environment.get("DATABASE_PASSWORD") ?? "admin_password",
        database: Environment.get("DATABASE_NAME") ?? "auto24_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)
    app.migrations.add(CreateItem())
    app.migrations.add(CreateUser())
    app.migrations.add(CreateItemImage())
    try app.autoMigrate().wait()
    // register routes
    try routes(app)
    app.middleware.use(app.sessions.middleware)
}
