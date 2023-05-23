//
//  LoginResponseDTO.swift
//  
//
//  Created by Raphael Torquato on 23/05/23.
//

import Foundation
import Vapor

struct LoginResponseDTO: Content {
    let error: Bool
    var reason: String? = nil
    let token: String?
    let userId: UUID
}
