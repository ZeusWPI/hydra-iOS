//
//  Association.swift
//
//  Created by Feliciaan De Palmenaer on 28/02/2016
//  Copyright (c) . All rights reserved.
//

import Foundation
import ObjectMapper

class Association: NSObject, NSCoding, Mappable {

    // MARK: Properties
	var internalName: String
	var displayName: String
	var parentAssociation: String?
	var fullName: String?

    var displayedFullName: String {
        get {
            if let fullName = fullName {
                return fullName
            }
            return displayName
        }
    }

    override var description: String {
        get {
            return "Association: \(self.internalName)"
        }
    }

    init(internalName: String, displayName: String) {
        self.internalName = internalName
        self.displayName = displayName
    }


    // MARK: ObjectMapper Initalizers
    /**
    Map a JSON object to this class using ObjectMapper
    - parameter map: A mapping from ObjectMapper
    */
    required convenience init?(_ map: Map){
        // Give empty values, because they will get filled
        self.init(internalName: "", displayName: "")
    }

    /**
     Map a JSON object to this class using ObjectMapper
     - parameter map: A mapping from ObjectMapper
     */
    func mapping(map: Map) {
        internalName <- map[PropertyKey.associationInternalNameKey]
        displayName <- map[PropertyKey.associationDisplayNameKey]
        parentAssociation <- map[PropertyKey.associationParentAssociationKey]
        fullName <- map[PropertyKey.associationFullNameKey]
        
    }

    // MARK: NSCoding Protocol
    required init(coder aDecoder: NSCoder) {
		self.internalName = aDecoder.decodeObjectForKey(PropertyKey.associationInternalNameKey) as! String
		self.displayName = aDecoder.decodeObjectForKey(PropertyKey.associationDisplayNameKey) as! String
		self.parentAssociation = aDecoder.decodeObjectForKey(PropertyKey.associationParentAssociationKey) as? String
		self.fullName = aDecoder.decodeObjectForKey(PropertyKey.associationFullNameKey) as? String

    }

    func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(internalName, forKey: PropertyKey.associationInternalNameKey)
		aCoder.encodeObject(displayName, forKey: PropertyKey.associationDisplayNameKey)
		aCoder.encodeObject(parentAssociation, forKey: PropertyKey.associationParentAssociationKey)
		aCoder.encodeObject(fullName, forKey: PropertyKey.associationFullNameKey)
    }

    func matches(query: String) -> Bool {
        if internalName.contains(query) || displayName.contains(query) {
            return true
        }
        if let fullName = fullName where fullName.contains(query) {
            return true
        }
        return false
    }

    struct PropertyKey {
        // MARK: Declaration for string constants to be used to decode and also serialize.
        static let associationInternalNameKey: String = "internal_name"
        static let associationDisplayNameKey: String = "display_name"
        static let associationParentAssociationKey: String = "parent_association"
        static let associationFullNameKey: String = "full_name"
    }
}
