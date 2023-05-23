import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("api")
        users.get(use: index)
        /* api/register */
        users.post("register", use: register)
        users.group(":id") { todo in
            todo.delete(use: delete)
        }
    }

    func index(req: Request) async throws -> [User] {
        try await User.query(on: req.db).all()
    }
    
    func login(req: Request) async throws -> String {
        //  Decode the request
        let user = try req.content.decode(User.self)
        // Check if the user exists in the database
        
        guard let existingUser = try await User.query(on: req.db)
            .filter(\.$username == user.username)
            .first() else {
                throw Abort(.badRequest)
            }
        
        //  validate the password
        
        let result = try await req.password.async.verify(user.password, created: existingUser.password)
        
        if !result {
            throw Abort(.unauthorized)
        }
        
        // generate the token and return it to the user
        
        
        
        return "Ok"
    }

    func register(req: Request) async throws -> RegisterResponseDTO {
        /* Validate the user */
        try User.validate(content: req)
        let user = try req.content.decode(User.self)
        /* Verify if username is valid */
        if let _ = try await User.query(on: req.db)
            .filter(\.$username == user.username)
            .first() {
            throw Abort(.conflict, reason: "This username is already taken")
        }
        /* Hash the password */
        user.password = try await req.password.async.hash(user.password)
        try await user.save(on: req.db)
        return RegisterResponseDTO(error: false)
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let user = try await User.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await user.delete(on: req.db)
        return .noContent
    }
}
