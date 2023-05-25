//
//  LoginResponseDTO+Extensions.swift
//  grocery-app-vapor-server
//
//  Created by Raphael Torquato on 24/05/23.
//

import Foundation
import GroceryAppSharedDTO
import Vapor

extension LoginResponseDTO: Content {}

extension RegisterResponseDTO: Content {}

extension GroceryCategoryRequestDTO: Content {}

extension GroceryCategoryResponseDTO: Content {
    
    init?(_ groceryCategory: GroceryCategory) {
        guard let id = groceryCategory.id else { return nil }
        self.init(id: id, title: groceryCategory.title ?? "", colorCode: groceryCategory.colorCode)
    }
}
