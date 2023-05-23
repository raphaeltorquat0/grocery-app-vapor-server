//
//  AuthPayLoad.swift
//  
//
//  Created by Raphael Torquato on 22/05/23.
//

import Foundation
import Vapor
import JWT

struct AuthPayLoad: JWTPayload {
    
    typealias Payload = AuthPayLoad
    
    var subject: SubjectClaim
    var expiration: ExpirationClaim
    var userId: UUID
    
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case userId = "uid"
    }
    
    
    func verify(using signer: JWTSigner) throws {
        try self.expiration.verifyNotExpired()
    }
}
