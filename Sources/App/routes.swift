import Fluent
import FluentPostgreSQL
import Leaf
import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
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

    router.post(Word.self, at: "create") { req, word -> Future<Word> in
        return word.save(on: req)
    }
    
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
    
    router.get("list") { req -> Future<[Word]> in
        return Word.query(on: req).all()
    }
    
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
    
    router.get("users", "create") { req -> Future<View> in
        return try req.view().render("users-create")
    }
}

func getUsername(_ req: Request) -> String? {
    return "Fake user"
}
