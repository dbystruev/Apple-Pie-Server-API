import Crypto
import Fluent
import FluentPostgreSQL
import Leaf
import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    // MARK: - JSON
    // MARK: - GET /categories
    router.get("categories") { req -> Future<[Category]> in
        return Category.query(on: req).all()
    }

    // MARK: - GET /words/<category-id>
    router.get("words", Int.parameter) { req -> Future<[CategoryWord]> in
        // get category ID
        let categoryID = try req.parameters.next(Int.self)

        // find category in database
        return Category.find(categoryID, on: req).flatMap(to: [CategoryWord].self) { category in
            guard let category = category else {
                throw Abort(.notFound)
            }

            return CategoryWord.query(on: req)
                .filter(\.category == category.id!)
                .all()
        }
    }

    // MARK: - GET /list
    router.get("list") { req -> Future<[Word]> in
        return Word.query(on: req).all()
    }
    
    // MARK: POST /create -
    router.post(Word.self, at: "create") { req, word -> Future<Word> in
        return word.save(on: req)
    }
    
    // MARK: - LEAF
    // MARK: - GET /
    router.get() { req -> Future<View> in
        struct HomeContext: Codable {
            var username: String?
            var categories: [Category]
        }
        
        return Category.query(on: req).all().flatMap(to: View.self) { categories in
            let context = HomeContext(username: getUsername(req), categories: categories)
            return try req.view().render("home", context)
        }
    }
    
    // MARK: GET /category/<category-id>
    router.get("category", Int.parameter) { req -> Future<View> in
        struct CategoryContext: Codable {
            var username: String?
            var category: Category
            var words: [CategoryWord]
        }
        
        // get category ID
        let categoryID = try req.parameters.next(Int.self)
        
        // look for category in the database
        return Category.find(categoryID, on: req).flatMap(to: View.self) { category in
            guard let category = category else {
                // category does not exist — abort
                throw Abort(.notFound)
            }
            
            let query = CategoryWord.query(on: req)
                .filter(\.category == category.id!)
                .all()
            
            // convert data into a Leaf view
            return query.flatMap(to: View.self) { words in
                let context = CategoryContext(username: getUsername(req), category: category, words: words)
                return try req.view().render("category", context)
            }
        }
    }
    
    // MARK: GET /setup
    router.get("setup") { req -> String in
//        let categories = [
//            Category(id: 1, name: "Фрукты"),
//            Category(id: 2, name: "Города"),
//            Category(id: 3, name: "Имена")
//        ]
//
//        categories.forEach {
//            _ = $0.create(on: req)
//        }
        
        let words = [
            CategoryWord(id: 1, category: 1, title: "Яблоко", user: "admin", date: Date()),
            CategoryWord(id: 2, category: 1, title: "Груша", user: "admin", date: Date()),
            CategoryWord(id: 3, category: 1, title: "Слива", user: "admin", date: Date()),
            CategoryWord(id: 4, category: 2, title: "Москва", user: "admin", date: Date()),
            CategoryWord(id: 5, category: 2, title: "Париж", user: "admin", date: Date()),
            CategoryWord(id: 6, category: 2, title: "Нью-Йорк", user: "admin", date: Date()),
            CategoryWord(id: 7, category: 2, title: "Киев", user: "admin", date: Date()),
            CategoryWord(id: 8, category: 2, title: "Минск", user: "admin", date: Date()),
            CategoryWord(id: 9, category: 2, title: "Нурсултан", user: "admin", date: Date()),
        ]
        
        words.forEach {
            _ = $0.create(on: req)
        }
        
        return "Database setup OK"
    }
    
    // MARK: GET /users/create
    router.get("users", "create") { req -> Future<View> in
        return try req.view().render("users-create")
    }
    
    // MARK: GET /users/login
    router.get("users", "login") { req -> Future<View> in
        return try req.view().render("users-login")
    }
    
    // MARK: GET /users/logout
    router.get("users", "logout") { req -> Future<View> in
        let session = try req.session()
        session["username"] = nil
        return try req.view().render("users-logout")
    }
    
    // MARK: POST /user/create
    router.post("users", "create") { req -> Future<View> in
        var user = try req.content.syncDecode(User.self)
        
        return User.query(on: req)
            .filter(\.username == user.username)
            .first()
            .flatMap(to: View.self) { existing in
                if existing == nil {
                    user.password = try BCrypt.hash(user.password)
                    
                    return user.save(on: req).flatMap(to: View.self) { user in
                        return try req.view().render("users-welcome")
                    }
                } else {
                    let context = ["error": "true"]
                    return try req.view().render("users-create", context)
                }
            }
    }
    
    // MARK: POST /user/login
    router.post(User.self, at: "users", "login") { req, user -> Future<View> in
        return User.query(on: req)
            .filter(\.username == user.username)
            .first()
            .flatMap(to: View.self) { existing in
                if let existing = existing {
                    if try BCrypt.verify(user.password, created: existing.password) {
                        let session = try req.session()
                        session["username"] = existing.username
                        let context = ["username": existing.username]
                        return try req.view().render("users-welcome", context)
                    }
                }
                
                let context = ["error": "true"]
                return try req.view().render("users-login", context)
        }
    }
}

func getUsername(_ req: Request) -> String? {
    let session = try? req.session()
    return session?["username"]
}
