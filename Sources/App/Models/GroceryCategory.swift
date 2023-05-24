//
//  GroceryCategory.swift
//  
//
//  Created by Raphael Torquato on 24/05/23.
//

import Foundation
import Fluent
import Vapor

final class CroceryCategory: Model, Content, Validatable {
    
    static let schema = "grocery_categories"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String?

    @Field(key: "color_code")
    var colorCode: String
    
    @Parent(key: "user_id")
    var user: User
    
    init() { }
    
    init(id: UUID? = nil, title: String, colorCode: String, userId: UUID) {
        self.title = title
        self.colorCode = colorCode
        self.$user.id = userId
    }
    
    static func validations(_ validations: inout Validations) {
        validations.add("title", as: String.self, is: !.empty, customFailureDescription: "Title cannot be empty.")
        validations.add("color_code", as: String.self, is: !.empty, customFailureDescription: "Color cannot be empty.")
    }
}

