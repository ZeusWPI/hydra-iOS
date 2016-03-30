//
//  Association.swift
//
//  Created by Feliciaan De Palmenaer on 28/02/2016
//  Copyright (c) . All rights reserved.
//

import Foundation
import ObjectMapper

class Association: NSObject, NSCoding, Mappable {

    // MARK: Declaration for string constants to be used to decode and also serialize.
	private let kAssociationInternalNameKey: String = "internal_name"
	private let kAssociationDisplayNameKey: String = "display_name"
	private let kAssociationParentAssociationKey: String = "parent_association"
	private let kAssociationFullNameKey: String = "full_name"

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
        internalName <- map[kAssociationInternalNameKey]
        displayName <- map[kAssociationDisplayNameKey]
        parentAssociation <- map[kAssociationParentAssociationKey]
        fullName <- map[kAssociationFullNameKey]
        
    }

    // MARK: NSCoding Protocol
    required init(coder aDecoder: NSCoder) {
		self.internalName = aDecoder.decodeObjectForKey(kAssociationInternalNameKey) as! String
		self.displayName = aDecoder.decodeObjectForKey(kAssociationDisplayNameKey) as! String
		self.parentAssociation = aDecoder.decodeObjectForKey(kAssociationParentAssociationKey) as? String
		self.fullName = aDecoder.decodeObjectForKey(kAssociationFullNameKey) as? String

    }

    func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(internalName, forKey: kAssociationInternalNameKey)
		aCoder.encodeObject(displayName, forKey: kAssociationDisplayNameKey)
		aCoder.encodeObject(parentAssociation, forKey: kAssociationParentAssociationKey)
		aCoder.encodeObject(fullName, forKey: kAssociationFullNameKey)
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
}
