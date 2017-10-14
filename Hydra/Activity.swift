//
//  Activity.swift
//
//  Created by Feliciaan De Palmenaer on 27/02/2016
//  Copyright (c) . All rights reserved.
//

import Foundation

struct Activity: Codable {

    // MARK: Properties
    var title: String
    var association: Association
    var start: Date
    var end: Date?
    var location: String
    var latitude: Double
    var longitude: Double
    var descriptionText: String
    var url: String
    var facebookId: String?
    var _highlighted: Int
    
    var highlighted: Bool {
        get {
            return 1 == _highlighted
        }
    }
    
    var facebookEvent: FacebookEvent? {
        get {
            return nil
        }
    }
    
    var description: String {
        get {
            return "Activity: \(self.title)"
        }
    }
    
    func hasCoordinates() -> Bool {
        return longitude != 0.0 && latitude != 0.0
    }

    func hasFacebookEvent() -> Bool {
        // TODO: readd FB event
        return false
    }
    
    private enum CodingKeys: String, CodingKey {
        case title
        case association
        case longitude
        case descriptionText = "description"
        case start
        case latitude
        case location
        case end
        case url
        case _highlighted = "highlighted"
        case facebookId = "facebook_id"
    }
}
