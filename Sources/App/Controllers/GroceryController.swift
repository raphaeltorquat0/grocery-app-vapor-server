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

         BASE API GROUPED:
         /* /api/users/:userID */
         /* /api/users/:userID */
         POST: Saving Grocery App
         * /api/users/:userId/grocery-categories
         * /api/users/:userId/grocery-categories/:groceryCategoryId/grocery-items
         GET: Grocery Categories By User
         * /api/users/:userId/grocery-categories
         * /api/users/:userId/grocery-categories/:groceryCategoryId/grocery-items
         DELETE:
         * /api/users/:userId/grocery-categories/:groceryCategoryId
         * /api/users/:UserId/grocery-categories/:groceryCategoryId/grocery-items/:groceryItemId
         DELETE:
         * /api/users/:userId/grocery-categories/:groceryCategoryId
         

         */
        
        let api = routes.grouped("api", "users", ":userId")
        api.post("grocery-categories", use: saveGroceryCategory)
        api.get("grocery-categories", use: getGroceryCategoriesByUSer)
        api.delete("grocery-categories", ":groceryCategoryId", use: deleteGroceryCategory)
        api.post("grocery-categories", ":groceryCategoryId", "grocery-items", use: saveGroceryItem)
        api.get("grocery-categories", ":groceryCategoryId", "grocery-items", use: getGroceryItemByGroceryCategory)
        api.get("grocery-categories", ":groceryCategoryId", "grocery-items", ":groceryItemId", use: deteleGroceryItem)

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

        let groceryItem = GroceryItem(title: groceryItemRequestDTO.title, price: groceryItemRequestDTO.price, quantity: groceryItemRequestDTO.quantity, groceryCategoryId: groceryCategory.id!)

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
    
    private func getGroceryItemByGroceryCategory(req: Request) async throws -> [GroceryItemResponseDTO] {
        
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
        
        return try await GroceryItem.query(on: req.db)
            .filter(\.$groceryCategory.$id == groceryCategory.id!)
            .all()
            .compactMap(GroceryItemResponseDTO.init)
    }
    
    private func deteleGroceryItem(req: Request) async throws -> GroceryItemResponseDTO {
        
        guard let userId = req.parameters.get("userId", as: UUID.self),
              let groceryCategoryId = req.parameters.get("groceryCategoryId", as: UUID.self),
              let groceryItemId = req.parameters.get("groceryItemId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let _ = try await User.find(userId, on: req.db) else {
            throw Abort(.badRequest)
        }
         
        guard let groceryCategory = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first() else {
            throw Abort(.notFound)
        }
        
        guard let groceryItem = try await GroceryItem.query(on: req.db)
            .filter(\.$id == groceryItemId)
            .filter(\.$groceryCategory.$id == groceryCategory.id!)
            .first() else {
                throw Abort(.notFound)
        }
        
        try await groceryItem.delete(on: req.db)
        
        guard let groceryItemResponseDTO = GroceryItemResponseDTO(groceryItem) else {
            throw Abort(.internalServerError)
        }
        
        return groceryItemResponseDTO
    }
}
