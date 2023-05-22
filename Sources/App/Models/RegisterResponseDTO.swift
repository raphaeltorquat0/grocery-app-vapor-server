//
//  RegisterResponseDTO.swift
//  
//
//  Created by Raphael Torquato on 20/05/23.
//

import Foundation
import Vapor

struct RegisterResponseDTO: Content {
    let error: Bool
    var reason: String? = nil
}
