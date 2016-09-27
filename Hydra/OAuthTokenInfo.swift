//
//  OAuthUser.swift
//
//  Created by Feliciaan De Palmenaer on 23/02/2016
//  Copyright (c) Zeus WPI. All rights reserved.
//

import Foundation
import ObjectMapper

class OAuthTokenInfo: NSObject, NSCoding, Mappable {

    // MARK: Properties
	var createdAt: String?
	var updatedAt: String?
	var user: User?
	var expiresIn: String?
	var scopes: [String]?

    // MARK: ObjectMapper Initalizers
    /**
    Map a JSON object to this class using ObjectMapper
    - parameter map: A mapping from ObjectMapper
    */
    required init?(map: Map){

    }

    /**
     Map a JSON object to this class using ObjectMapper
     - parameter map: A mapping from ObjectMapper
     */
    func mapping(map: Map) {
        createdAt <- map[PropertyKey.oAuthUserCreatedAtKey]
        updatedAt <- map[PropertyKey.oAuthUserUpdatedAtKey]
        user <- map[PropertyKey.oAuthUserUserKey]
        expiresIn <- map[PropertyKey.oAuthUserExpiresInKey]
        scopes <- map[PropertyKey.oAuthUserScopesKey]
    }

    // MARK: NSCoding Protocol
    required init(coder aDecoder: NSCoder) {
		self.createdAt = aDecoder.decodeObject(forKey: PropertyKey.oAuthUserCreatedAtKey) as? String
		self.updatedAt = aDecoder.decodeObject(forKey: PropertyKey.oAuthUserUpdatedAtKey) as? String
		self.user = aDecoder.decodeObject(forKey: PropertyKey.oAuthUserUserKey) as? User
		self.expiresIn = aDecoder.decodeObject(forKey: PropertyKey.oAuthUserExpiresInKey) as? String
		self.scopes = aDecoder.decodeObject(forKey: PropertyKey.oAuthUserScopesKey) as? [String]

    }

    func encode(with aCoder: NSCoder) {
		aCoder.encode(createdAt, forKey: PropertyKey.oAuthUserCreatedAtKey)
		aCoder.encode(updatedAt, forKey: PropertyKey.oAuthUserUpdatedAtKey)
		aCoder.encode(user, forKey: PropertyKey.oAuthUserUserKey)
		aCoder.encode(expiresIn, forKey: PropertyKey.oAuthUserExpiresInKey)
		aCoder.encode(scopes, forKey: PropertyKey.oAuthUserScopesKey)
    }

    // MARK: Declaration for string constants to be used to decode and also serialize.
    struct PropertyKey {
        static let oAuthUserCreatedAtKey: String = "created_at"
        static let oAuthUserUpdatedAtKey: String = "updated_at"
        static let oAuthUserUserKey: String = "user"
        static let oAuthUserAppKey: String = "app"
        static let oAuthUserExpiresInKey: String = "expires_in"
        static let oAuthUserScopesKey: String = "scopes"
    }
}
