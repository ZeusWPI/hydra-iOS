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
    var association: String
    var start: Date
    var end: Date?
    var location: String
    var address: String?
    var descriptionText: String?
    var url: String?
    
    var description: String {
        get {
            return "Activity: \(self.title)"
        }
    }

    func hasFacebookEvent() -> Bool {
        // TODO: readd FB event
        return false
    }
    
    private enum CodingKeys: String, CodingKey {
        case title
        case association
        case descriptionText = "description"
        case start = "start_time"
        case location
        case address
        case end = "end_time"
        case url = "infolink"
    }
}
