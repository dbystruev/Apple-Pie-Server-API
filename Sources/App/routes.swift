import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    router.get() { req -> Future<Word> in
        let word = Word(id: UUID(), value: "Get Value")

        return Future.map(on: req) { return word }
    }
    
    router.get("list") { req -> Future<[Word]> in
        return Word.query(on: req).all()
    }
    
    router.post(Word.self, at: "create") { req, word -> Future<Word> in
        return word.save(on: req)
    }
}
