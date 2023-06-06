import Fluent
import FluentPostgresDriver
import Vapor
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    if let dataBaseURL = Environment.get("DATABASE_URL"), var postgresConfig = PostgresConfiguration(url: dataBaseURL) {
        postgresConfig.tlsConfiguration = .makeClientConfiguration()
        postgresConfig.tlsConfiguration?.certificateVerification = .none
        app.databases.use(.postgres(configuration: postgresConfig), as: .psql)
    } else {
        app.databases.use(.postgres(hostname: Environment.get("DB_HOST_NAME") ?? "localhost", username: Environment.get("DB_USER_NAME") ?? "postgres", password: Environment.get("DB_PASSWORD") ?? "", database: Environment.get("DB_NAME") ?? "grocerydb"), as: .psql)
    }

    
    /* Register migrations*/
    app.migrations.add(CreateUsersTableMigration())
    app.migrations.add(CreateGroceryCategoryTableMigration())
    app.migrations.add(CreateGroceryItemTableMigration())
    /* Register the controllers */
    try app.register(collection: UserController())
    try app.register(collection: GroceryController())
    app.jwt.signers.use(.hs256(key: Environment.get("JWT_SIGN_KEY") ?? "SECRETKEY"))
    // register routes
    try routes(app)
}
