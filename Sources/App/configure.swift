import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import JWT

public func configure(_ app: Application) throws {
    // Увеличиваем максимально допустимый размер тела запроса
    app.routes.defaultMaxBodySize = "100mb"
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 8080

    app.databases.use(
        .postgres(
            configuration: .init(
                hostname: Environment.get("DATABASE_HOST") ?? "localhost",
                port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:))
                    ?? SQLPostgresConfiguration.ianaPortNumber,
                username: Environment.get("DATABASE_USERNAME") ?? "admin",
                password: Environment.get("DATABASE_PASSWORD") ?? "admin_password",
                database: Environment.get("DATABASE_NAME") ?? "auto24_database",
                tls: .prefer(try .init(configuration: .clientDefault))
            )
        ),
        as: .psql
    )
    
    app.migrations.add(CreateUser())
    app.migrations.add(CreateItem())
    app.migrations.add(CreateItemImage())
    if app.environment == .development {
        try app.autoMigrate().wait()
    }

    try routes(app)
    app.jwt.signers.use(.hs256(key: "5yh7PGL/pT7VOlXZ+DzwnrzrIWAViSlDjyaYihnaGhA="))
    app.middleware.use(app.sessions.middleware)
}
