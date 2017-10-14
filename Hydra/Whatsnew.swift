//
//  Whatsnew.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 02/08/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

class WhatsNew: Codable {

    var agenda = [CalendarItem]()
    var announcement = [Announcement]()
    
    private enum CodingKeys: String, CodingKey {
        case agenda, announcement
    }
}
