//
//  Association.swift
//
//  Created by Feliciaan De Palmenaer on 28/02/2016
//  Copyright (c) . All rights reserved.
//

import Foundation

class Association: NSObject, Codable {

    // MARK: Properties
	@objc var internalName: String
	@objc var displayName: String
	var parentAssociation: String?
	var fullName: String?

    @objc var displayedFullName: String {
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
    

    @objc func matches(_ query: String) -> Bool {
        if internalName.contains(query) || displayName.contains(query) {
            return true
        }
        if let fullName = fullName, fullName.contains(query) {
            return true
        }
        return false
    }
    
    private enum CodingKeys: String, CodingKey {
        case internalName = "internal_name"
        case displayName = "display_name"
        case parentAssociation = "parent_association"
        case fullName = "full_name"
    }
}
