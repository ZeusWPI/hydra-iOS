//
//  Whatsnew.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 02/08/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import ObjectMapper

class WhatsNew: Mappable {

    var agenda = [CalendarItem]()
    var announcement = [Announcement]()

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.agenda <- map[PropertyKey.agendaKey]
        self.announcement <- map[PropertyKey.announcementsKey]
    }

    struct PropertyKey {
        static let agendaKey = "agenda"
        static let announcementsKey = "announcement"
    }
}
