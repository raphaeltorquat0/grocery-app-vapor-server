//
//  GroceryController.swift
//  
//
//  Created by Raphael Torquato on 24/05/23.
//

import Foundation
import Vapor
import GroceryAppSharedDTO
import Fluent

class GroceryController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        /*
            * /api/users/:userID
            POST: Saving Grocery App
            * /api/users/:userId/grocery-categories
         
         */
        
        let api = routes.grouped("api", "users", ":userId")
        api.post("grocery-categories", use: saveGroceryCategory)
        /* GET: /api/users/:userId/grocery-categories */
        
        api.get("grocery-categories", use: getGroceryCategoriesByUSer)
    }
    
    private func getGroceryCategoriesByUSer(req: Request) async throws -> [GroceryCategoryResponseDTO] {
        
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .all()
            .compactMap(GroceryCategoryResponseDTO.init)
        
    }
    
    
    private func saveGroceryCategory(req: Request) async throws -> GroceryCategoryResponseDTO {
        
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        /* DTO for the request */
        
        let groceryCategoryRequestDTO = try req.content.decode(GroceryCategoryRequestDTO.self)
        let groceryCategory = GroceryCategory(title: groceryCategoryRequestDTO.title, colorCode: groceryCategoryRequestDTO.colorCode, userId: userId)
        try await groceryCategory.save(on: req.db)
        
        /* DTO for the response*/
        
        guard let groceryCategoryResponseDTO = GroceryCategoryResponseDTO(groceryCategory) else {
            throw Abort(.internalServerError)
        }
        
        return groceryCategoryResponseDTO
    }
}
