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
         /* /api/users/:userID */
         
         POST: Saving Grocery App
         * /api/users/:userId/grocery-categories
         * /api/users/:userId/grocery-categories/:groceryCategoryId/grocery-items
         GET: Grocery Categories By User
         * /api/users/:userId/grocery-categories
         DELETE:
         * /api/users/:userId/grocery-categories/:groceryCategoryId
         
         */
        
        let api = routes.grouped("api", "users", ":userId")
        api.post("grocery-categories", use: saveGroceryCategory)
        api.get("grocery-categories", use: getGroceryCategoriesByUSer)
        api.delete("grocery-categories", ":groceryCategoryId", use: deleteGroceryCategory)
        api.post("grocery-categories", ":groceryCategoryId", "grocery-items", use: saveGroceryItem)
    }
    
    private func saveGroceryItem(req: Request) async throws -> GroceryItemResponseDTO {
        guard let userId = req.parameters.get("userId", as: UUID.self),
              let groceryCategoryId = req.parameters.get("groceryCategoryId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let _ = try await User.find(userId, on: req.db) else {
            throw Abort(.notFound)
        }
        
        guard let groceryCategory = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first() else {
            throw Abort(.notFound)
        }
        let groceryItemRequestDTO = try req.content.decode(GroceryItemRequestDTO.self)
        
        let groceryItem = GroceryItem(title: groceryItemRequestDTO.title, price: groceryItemRequestDTO.price, quantity: groceryItemRequestDTO.quantity, groceryCategoryId: groceryCategoryId)
        
        try await groceryItem.save(on: req.db)
        
        guard let groceryItemResponseDTO = GroceryItemResponseDTO(groceryItem) else {
            throw Abort(.internalServerError)
        }
        return groceryItemResponseDTO
    }
    
    private func deleteGroceryCategory(req: Request) async throws -> GroceryCategoryResponseDTO {
        
        guard let userId = req.parameters.get("userId", as: UUID.self),
              let groceryCategoryId = req.parameters.get("groceryCategoryId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let groceryCategory = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId).first() else {
            throw Abort(.notFound)
        }
        
        try await groceryCategory.delete(on: req.db)
        
        guard let groceryCategoryResponseDTO = GroceryCategoryResponseDTO(groceryCategory) else {
            throw Abort(.internalServerError)
        }
        
        return groceryCategoryResponseDTO
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
        
        let groceryCategoryRequestDTO = try req.content.decode(GroceryCategoryRequestDTO.self)
        let groceryCategory = GroceryCategory(title: groceryCategoryRequestDTO.title, colorCode: groceryCategoryRequestDTO.colorCode, userId: userId)
        try await groceryCategory.save(on: req.db)
        
        guard let groceryCategoryResponseDTO = GroceryCategoryResponseDTO(groceryCategory) else {
            throw Abort(.internalServerError)
        }
        
        return groceryCategoryResponseDTO
    }
}
