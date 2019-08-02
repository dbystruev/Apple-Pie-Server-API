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
    
    router.get("list") { req -> Future<[Word]> in
        return Word.query(on: req).all()
    }
    
    router.get("setup") { req -> String in
        let categories = [
            Category(id: 1, name: "Фрукты"),
            Category(id: 2, name: "Города"),
            Category(id: 3, name: "Имена")
        ]
        
        categories.forEach {
            _ = $0.create(on: req)
        }
        
        return "Database setup OK"
    }
}

func getUsername(_ req: Request) -> String? {
    return "Fake user"
}
