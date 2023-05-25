import Fluent
import FluentPostgresDriver
import Vapor
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.databases.use(.postgres(hostname: "localhost", username: "postgres", password: "", database: "grocerydb"), as: .psql)
    /* Register migrations*/
    app.migrations.add(CreateUsersTableMigration())
    app.migrations.add(CreateGroceryCategoryTableMigration())
    /* Register the controllers */
    try app.register(collection: UserController())
    try app.register(collection: GroceryController())
    app.jwt.signers.use(.hs256(key: "SECRETKEY"))
    // register routes
    try routes(app)
}
