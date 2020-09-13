//
//  Association.swift
//
//  Created by Feliciaan De Palmenaer on 28/02/2016
//  Copyright (c) . All rights reserved.
//

import Foundation

class Association: NSObject, Codable {

    // MARK: Properties
	@objc var abbreviation: String
	@objc var name: String
    @objc var path: [String]
    var email: String
    var logo: String
	var descriptionText: String?
	var website: String?

    override var description: String {
        get {
            return "Association: \(self.name)"
        }
    }
    
    init(abbreviation: String, name: String, path: [String], email: String, logo: String) {
        self.abbreviation = abbreviation
        self.name = name
        self.path = path
        self.email = email
        self.logo = logo
    }
    
    @objc func matches(_ query: String) -> Bool {
        if abbreviation.contains(query) || name.contains(query) {
            return true
        }
        return false
    }
    
    private enum CodingKeys: String, CodingKey {
        case abbreviation
        case name
        case path
        case email
        case logo
        case descriptionText = "description"
        case website
    }
}
