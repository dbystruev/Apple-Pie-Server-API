import Fluent
import FluentSQLite
import Vapor

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Configure the rest of your application here
    let directoryConfig = DirectoryConfig.detect()
    services.register(directoryConfig)
    
    try services.register(FluentSQLiteProvider())
    
    var databaseConfig = DatabasesConfig()
    let fullPath = "\(directoryConfig.workDir)words.db"
    print(#line, #function, "Path to DB:", fullPath)
    let db = try SQLiteDatabase(storage: .file(path: fullPath))
    databaseConfig.add(database: db, as: .sqlite)
    services.register(databaseConfig)
    
    var migrationConfig = MigrationConfig()
    migrationConfig.add(model: Word.self, database: .sqlite)
    services.register(migrationConfig)
}
