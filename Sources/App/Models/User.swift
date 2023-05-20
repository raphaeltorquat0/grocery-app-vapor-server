import Fluent
import Vapor

final class User: Model, Validatable {
    static let schema = "users"
    /* ID */
    @ID(key: .id)
    var id: UUID?
    /* USERNAME */
    @Field(key: "username")
    var username: String
    /* PASSWORD */
    @Field(key: "password")
    var password: String
    /* EMAIL */
    @Field(key: "email")
    var email: String

    init() { }

    init(id: UUID? = nil, username: String, password: String, email: String) {
        self.id = id
        self.username = username
        self.password = password
        self.email = email
    }
    
    static func validations(_ validations: inout Validations) {
        validations.add("username", as: String.self, is: !.empty, customFailureDescription: "Username cannot be empty.")
        validations.add("password", as: String.self, is: !.empty, customFailureDescription: "password cannot be empty.")
        validations.add("password", as: String.self, is: .count(6...10), customFailureDescription: "password cannot be empty.")
        validations.add("email", as: String.self, is: !.empty, customFailureDescription: "email cannot be empty.")
    }
}
