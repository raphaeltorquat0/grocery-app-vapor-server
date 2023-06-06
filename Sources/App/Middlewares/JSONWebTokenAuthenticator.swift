//
//  JSONWebTokenAuthenticator.swift
//  
//
//  Created by Raphael Torquato on 05/06/23.
//

import Foundation
import Vapor

struct JSONWebTokenAuthenticator: AsyncRequestAuthenticator {
    
    func authenticate(request: Request) async throws {
        try request.jwt.verify(as: AuthPayLoad.self)
    }
}
