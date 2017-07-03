//
//  OAuthUser.swift
//
//  Created by Feliciaan De Palmenaer on 23/02/2016
//  Copyright (c) Zeus WPI. All rights reserved.
//

import Foundation
import ObjectMapper

class OAuthTokenInfo: NSObject, Codable {

    // MARK: Properties
	var createdAt: String?
	var updatedAt: String?
	var user: User?
	var expiresIn: String?
	var scopes: [String]?

    // MARK: Declaration for string constants to be used to decode and also serialize.
    private enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case user, scopes
        case expiresIn = "expires_in"
    }
}
