//
//  OAuthUser.swift
//
//  Created by Feliciaan De Palmenaer on 23/02/2016
//  Copyright (c) Zeus WPI. All rights reserved.
//

import Foundation
import ObjectMapper

class OAuthTokenInfo: NSObject, NSCoding, Mappable {

    // MARK: Declaration for string constants to be used to decode and also serialize.
	private let kOAuthUserCreatedAtKey: String = "created_at"
	private let kOAuthUserUpdatedAtKey: String = "updated_at"
	private let kOAuthUserUserKey: String = "user"
	private let kOAuthUserAppKey: String = "app"
	private let kOAuthUserExpiresInKey: String = "expires_in"
	private let kOAuthUserScopesKey: String = "scopes"


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
    required init?(_ map: Map){

    }

    /**
     Map a JSON object to this class using ObjectMapper
     - parameter map: A mapping from ObjectMapper
     */
    func mapping(map: Map) {
        createdAt <- map[kOAuthUserCreatedAtKey]
        updatedAt <- map[kOAuthUserUpdatedAtKey]
        user <- map[kOAuthUserUserKey]
        expiresIn <- map[kOAuthUserExpiresInKey]
        scopes <- map[kOAuthUserScopesKey]
    }

    // MARK: NSCoding Protocol
    required init(coder aDecoder: NSCoder) {
		self.createdAt = aDecoder.decodeObjectForKey(kOAuthUserCreatedAtKey) as? String
		self.updatedAt = aDecoder.decodeObjectForKey(kOAuthUserUpdatedAtKey) as? String
		self.user = aDecoder.decodeObjectForKey(kOAuthUserUserKey) as? User
		self.expiresIn = aDecoder.decodeObjectForKey(kOAuthUserExpiresInKey) as? String
		self.scopes = aDecoder.decodeObjectForKey(kOAuthUserScopesKey) as? [String]

    }

    func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(createdAt, forKey: kOAuthUserCreatedAtKey)
		aCoder.encodeObject(updatedAt, forKey: kOAuthUserUpdatedAtKey)
		aCoder.encodeObject(user, forKey: kOAuthUserUserKey)
		aCoder.encodeObject(expiresIn, forKey: kOAuthUserExpiresInKey)
		aCoder.encodeObject(scopes, forKey: kOAuthUserScopesKey)
    }

}
