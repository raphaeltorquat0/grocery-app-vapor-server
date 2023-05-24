import Fluent
import Vapor

struct UserController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("api")
        api.get(use: index)
        /* api/register */
        api.post("register", use: register)
        api.group(":id") { todo in
            todo.delete(use: delete)
        }
        /* api/login */
        api.post("login", use: login)
    }

    func index(req: Request) async throws -> [User] {
        try await User.query(on: req.db).all()
    }
    
    func login(req: Request) async throws -> LoginResponseDTO {
        //  Decode the request
        let user = try req.content.decode(User.self)
        // Check if the user exists in the database
        
        guard let existingUser = try await User.query(on: req.db)
            .filter(\.$username == user.username)
            .first() else {
                return LoginResponseDTO(error: true, reason: "username is not found.")
            }
        
        //  validate the password
        
        let result = try await req.password.async.verify(user.password, created: existingUser.password)
        
        if !result {
            return LoginResponseDTO(error: true, reason: "password is incorrect.")
        }
        
        // generate the token and return it to the user
        let authPayload = try AuthPayLoad(subject: .init(value: "Grocery App"), expiration: .init(value: .distantFuture), userId: existingUser.requireID())
        return try LoginResponseDTO(error: false, token: req.jwt.sign(authPayload), userId: existingUser.requireID())
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
