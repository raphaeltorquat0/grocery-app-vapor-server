//
//  GroceryController.swift
//  
//
//  Created by Raphael Torquato on 24/05/23.
//

import Foundation
import Vapor


class GroceryController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        /*
            * /api/users/:userID
            POST: Saving Grocery App
            * /api/users/:userId/grocery-categories
         
         */
        
        let api = routes.grouped("api", "users", ":userId")
        api.post("grocery-categories", use: saveGroceryCategory)
    }
    
    private func saveGroceryCategory(req: Request) async throws -> String {
            /* DTO for the request */
            /* DTO for the response*/
        return "OK"
    }
}
