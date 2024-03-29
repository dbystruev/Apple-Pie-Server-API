import Fluent
//import FluentSQLite
//import FluentMySQL
import FluentPostgreSQL
import Leaf
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
    
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    
    try services.register(FluentPostgreSQLProvider())
    
//    try services.register(FluentMySQLProvider())
    
//    try services.register(FluentSQLiteProvider())
//
//    var databaseConfig = DatabasesConfig()
//    let fullPath = "\(directoryConfig.workDir)words.db"
//    print(#line, #function, "Path to DB:", fullPath)
//    let db = try SQLiteDatabase(storage: .file(path: fullPath))
//    databaseConfig.add(database: db, as: .sqlite)
//    services.register(databaseConfig)
    
//    let mysqlConfig = MySQLDatabaseConfig(hostname: "mysql", port: 3306, username: "root", password: "mysqlpass1", database: "words", capabilities: MySQLCapabilities(), characterSet: .utf8_general_ci, transport: .cleartext)
//    let mysql = MySQLDatabase(config: mysqlConfig)
//
//    var databaseConfig = DatabasesConfig()
//    databaseConfig.add(database: mysql, as: .mysql)
//    services.register(databaseConfig)
    
    let postgresConfig = PostgreSQLDatabaseConfig(hostname: "postgres", port: 5432, username: "postgres", database: nil, password: "postgrespassword1", transport: .cleartext)
    let postgresql = PostgreSQLDatabase(config: postgresConfig)
    
    var databasesConfig = DatabasesConfig()
    databasesConfig.add(database: postgresql, as: .psql)
    services.register(databasesConfig)
    
    var migrationConfig = MigrationConfig()
    migrationConfig.add(model: Category.self, database: .psql)
    migrationConfig.add(model: CategoryWord.self, database: .psql)
    migrationConfig.add(model: User.self, database: .psql)
    migrationConfig.add(model: Word.self, database: .psql)
    services.register(migrationConfig)
    
    var middlewareConfig = MiddlewareConfig.default()
    middlewareConfig.use(SessionsMiddleware.self)
    services.register(middlewareConfig)
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
}
